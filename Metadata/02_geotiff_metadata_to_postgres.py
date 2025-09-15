#coding: utf-8

import os
import sys
import psycopg2
from osgeo import gdal, osr
import math

gdal.UseExceptions()  # Explicitly enable exceptions

def transform_to_wgs84(x, y, source_srs):
    """Transform coordinates from source projection to EPSG:4326 (lat/lon)."""
    target_srs = osr.SpatialReference()
    target_srs.ImportFromEPSG(4326)
    transform = osr.CoordinateTransformation(source_srs, target_srs)
    lon, lat, _ = transform.TransformPoint(x, y)
    return lon, lat

def convert_size(size_bytes):
   if size_bytes == 0:
       return "0B"
   size_name = ("B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB")
   i = int(math.floor(math.log(size_bytes, 1024)))
   p = math.pow(1024, i)
   s = round(size_bytes / p, 2)
   return "%s %s" % (s, size_name[i])

def spatial_data_scan(INPUT_DIR):

    print("Extracting metadata from GeoTIFF's ...")
    # iterate files
    for subdir, dirs, files in os.walk(INPUT_DIR):
        for file in files:

            # diccionary to store variables
            dic_gdal_num={}
            dic_gdal_text={}

            # get path
            file_name = str(file)
            file_path = str(subdir)
            path = os.path.join(subdir, file)
            file_extension = os.path.splitext(file)[-1].lstrip('.').lower()

            if file_extension in ['asc', 'ecw', 'grb', 'rb2', 'hdf', 'jpg', 'nc', 'tif']:

                # file metadata
                file_stat = os.stat(path)
                file_size = file_stat[6]
                file_size_pretty = convert_size(file_stat[6])
                layer_id = file_name[:-4]
                country_id = layer_id.split('-')[0]
                project_id = layer_id.split('-')[1]
                property_id = layer_id.split('-')[2]
                mapset_id = '-'.join(layer_id.split('-')[:4])

                # insert project
                sql = f"INSERT INTO spatial_metadata.project(country_id, project_id) VALUES('{country_id}', '{project_id}') ON CONFLICT (country_id, project_id) DO NOTHING"
                cur.execute(sql)

                # insert mapset and layer
                print (file_name)
                sql = f"INSERT INTO spatial_metadata.mapset(country_id, project_id, property_id, mapset_id) VALUES('{country_id}', '{project_id}', '{property_id}', '{mapset_id}') ON CONFLICT (mapset_id) DO NOTHING"
                cur.execute(sql)
                dimension_depth = layer_id.split('-')[4] + '-' + layer_id.split('-')[5]
                dimension_stats = layer_id.split('-')[6]
                sql = f"INSERT INTO spatial_metadata.layer(mapset_id, dimension_depth, dimension_stats, file_path, layer_id, file_extension, file_size, file_size_pretty) VALUES('{mapset_id}', '{dimension_depth}', '{dimension_stats}','{file_path}','{layer_id}','{file_extension}','{file_size}','{file_size_pretty}')"
                cur.execute(sql)

                # open file with GDAL
                src_ds = gdal.Open(path)
                if src_ds is None:
                    print ('Unable to open %s' % path)
                    sys.exit(1)

                # GDAL info
                image_struture = src_ds.GetMetadata('IMAGE_STRUCTURE')
                dic_gdal_text['compression'] = image_struture.get('COMPRESSION', None) if image_struture else None
                dic_gdal_text['distribution_format'] = src_ds.GetDriver().LongName
                dic_gdal_num['raster_size_x'] = src_ds.RasterXSize
                dic_gdal_num['raster_size_y'] = src_ds.RasterYSize
                geo_transform = src_ds.GetGeoTransform()
                dic_gdal_num['distance'] = abs(geo_transform[1])
                dic_gdal_num['pixel_size_x'] = abs(geo_transform[1])
                dic_gdal_num['pixel_size_y'] = abs(geo_transform[5])
                dic_gdal_num['origin_x'] = geo_transform[0]
                dic_gdal_num['origin_y'] = geo_transform[3]

                projection = src_ds.GetProjection()
                spatial_reference = osr.SpatialReference()
                spatial_reference.ImportFromWkt(projection)
                # Check if the CRS is projected or geographic
                spatial_reference.ImportFromWkt(projection)
                if spatial_reference.IsProjected():
                    dic_gdal_text['distance_uom'] = 'm'
                elif spatial_reference.IsGeographic():
                    dic_gdal_text['distance_uom'] = 'deg'
                dic_gdal_text['reference_system_identifier_code'] = spatial_reference.GetAttrValue('AUTHORITY',1)
                dic_gdal_text['spatial_reference'] = str(spatial_reference)
                dic_gdal_num['n_bands'] = src_ds.RasterCount
                dic_gdal_text['metadata'] = str(src_ds.GetMetadata()).replace("'","")
                
                # Bounding Box
                west_x = geo_transform[0]  # Upper-left X
                north_y = geo_transform[3]  # Upper-left Y
                east_x = west_x + (src_ds.RasterXSize * geo_transform[1])  # Lower-right X
                south_y = north_y + (src_ds.RasterYSize * geo_transform[5])  # Lower-right Y
                dic_gdal_text['extent'] = f'{west_x} {south_y} {east_x} {north_y}'
                west_lon, north_lat = transform_to_wgs84(west_x, north_y, spatial_reference) # in EPSG:4326
                east_lon, south_lat = transform_to_wgs84(east_x, south_y, spatial_reference) # in EPSG:4326
                dic_gdal_num['west_bound_longitude'] = west_lon
                dic_gdal_num['east_bound_longitude'] = east_lon
                dic_gdal_num['north_bound_latitude'] = north_lat
                dic_gdal_num['south_bound_latitude'] = south_lat

                # iterate bands
                for band_number in range(src_ds.RasterCount):
                    band_number += 1
                    src_band = src_ds.GetRasterBand(band_number)
                    if src_band is None:
                        continue
                    stats = src_band.GetStatistics(False, True)
                    if stats is None:
                        continue

                    # band info
                    dic_gdal_text['data_type']    = gdal.GetDataTypeName(src_band.DataType)
                    dic_gdal_num['no_data_value'] = -123456789 if src_band.GetNoDataValue() is None or str(src_band.GetNoDataValue()).lower() == 'nan' else src_band.GetNoDataValue()
                    dic_gdal_num['stats_minimum'] = stats[0]
                    dic_gdal_num['stats_maximum'] = stats[1]
                    dic_gdal_num['stats_mean']    = stats[2] if str(stats[2]) != 'nan' else -123456789
                    dic_gdal_num['stats_std_dev'] = stats[3] if str(stats[3]) != 'nan' else -123456789
                    dic_gdal_text['scale']        = src_band.GetScale()

                    # insert text data
                    for key, value in dic_gdal_text.items():
                        sql = f"UPDATE spatial_metadata.layer SET {key} = '{value}' WHERE layer_id = '{layer_id}' AND file_path = '{file_path}'"
                        cur.execute(sql)

                    # insert num data
                    for key, value in dic_gdal_num.items():
                        sql = f"UPDATE spatial_metadata.layer SET {key} = {value} WHERE layer_id = '{layer_id}' AND file_path = '{file_path}'"
                        cur.execute(sql)

            # commit changes in the DB per file
            conn.commit()

    # remove -123456789 values
    sql = """UPDATE spatial_metadata.layer SET compression = NULL WHERE compression='None';
             UPDATE spatial_metadata.layer SET stats_mean = NULL WHERE stats_mean=-123456789;
             UPDATE spatial_metadata.layer SET stats_std_dev = NULL WHERE stats_std_dev=-123456789;
             UPDATE spatial_metadata.layer SET no_data_value = NULL WHERE no_data_value=-123456789;"""
    cur.execute(sql)

    # update property min and max
    sql = """UPDATE spatial_metadata.property p
             SET min = t.min,
                 max = t.max
             FROM (SELECT split_part(mapset_id,'-',3) property_id, min(stats_minimum) min, max(stats_maximum) max FROM spatial_metadata.layer GROUP BY split_part(mapset_id,'-',3)) t
             WHERE p.property_id = t.property_id"""
    cur.execute(sql)


# open db connection
conn = psycopg2.connect("host='localhost' port='5432' dbname='iso19139' user='glosis'")
cur = conn.cursor()

# run function
INPUT_DIR = sys.argv[1]
spatial_data_scan(INPUT_DIR)

# close db connection
conn.commit()
cur.close()
conn.close()
