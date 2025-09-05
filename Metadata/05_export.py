#coding: utf-8

import sys
import psycopg2

def export_style(country_id, project_id, output_dir):
    
    print(f'Exporting XML, SLD, MAP for project {project_id} ...')

    # symbology
    sql = f"""  SELECT DISTINCT mapset_id, sld
                FROM spatial_metadata.mapset
                WHERE sld IS NOT NULL 
                  AND country_id = '{country_id}'
                  AND project_id = '{project_id}'
                ORDER BY mapset_id"""
    cur.execute(sql)
    rows = cur.fetchall()
    for row in rows:
        mapset_id = row[0]
        content = row[1]
        write_file = open(f'{output_dir}/{mapset_id}.sld','w')
        write_file.write(content)
        write_file.close

    # metadata
    sql = f"""  SELECT mapset_id, xml
                FROM spatial_metadata.mapset
                WHERE xml IS NOT NULL 
                  AND country_id = '{country_id}'
                  AND project_id = '{project_id}'
                ORDER BY mapset_id"""
    cur.execute(sql)
    rows = cur.fetchall()
    for row in rows:
        mapset_id = row[0]
        content = row[1]
        write_file = open(f'{output_dir}/{mapset_id}.xml','w')
        write_file.write(content)
        write_file.close
    
    # mapfile
    sql = f"""  SELECT l.layer_id, l.map
                FROM spatial_metadata.mapset m
                LEFT JOIN spatial_metadata.layer l ON l.mapset_id = m.mapset_id  
                WHERE l.map IS NOT NULL 
                  AND m.country_id = '{country_id}'
                  AND m.project_id = '{project_id}'
                ORDER BY l.layer_id"""
    cur.execute(sql)
    rows = cur.fetchall()
    for row in rows:
        layer_id = row[0]
        content = row[1]
        write_file = open(f'{output_dir}/{layer_id}.map','w')
        write_file.write(content)
        write_file.close
    return

# open db connection
conn = psycopg2.connect("host='localhost' port='5432' dbname='iso19139' user='glosis'")
cur = conn.cursor()

# run function
country_id = sys.argv[1]
project_id = sys.argv[2]
output_dir = sys.argv[3]
export_style(country_id, project_id, output_dir)

# close db connection
conn.commit()
cur.close()
conn.close()
