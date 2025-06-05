#coding: utf-8

import psycopg2

def export_style(output, country_id, project_id):
    
    print(f'Exporting XML, SLD, MAP for project {project_id} ...')

    # symbology
    sql = f"""  SELECT DISTINCT p.property_id, p.sld
                FROM metadata.mapset m
                LEFT JOIN metadata.property p ON p.property_id = m.property_id
                WHERE p.sld IS NOT NULL 
                  AND m.country_id = '{country_id}'
                  AND m.project_id = '{project_id}'
                ORDER BY p.property_id"""
    cur.execute(sql)
    rows = cur.fetchall()
    for row in rows:
        property = row[0]
        content = row[1]
        write_file = open(f'{output}/SOIL-{property}.sld','w')
        write_file.write(content)
        write_file.close

    # metadata
    sql = f"""  SELECT mapset_id, xml
                FROM metadata.mapset
                WHERE xml IS NOT NULL 
                  AND country_id = '{country_id}'
                  AND project_id = '{project_id}'
                ORDER BY mapset_id"""
    cur.execute(sql)
    rows = cur.fetchall()
    for row in rows:
        mapset = row[0]
        content = row[1]
        write_file = open(f'{output}/{mapset}.xml','w')
        write_file.write(content)
        write_file.close
    
    # mapfile
    sql = f"""  SELECT l.layer_id, l.map
                FROM metadata.mapset m
                LEFT JOIN metadata.layer l ON l.mapset_id = m.mapset_id  
                WHERE l.map IS NOT NULL 
                  AND m.country_id = '{country_id}'
                  AND m.project_id = '{project_id}'
                ORDER BY l.layer_id"""
    cur.execute(sql)
    rows = cur.fetchall()
    for row in rows:
        layer = row[0]
        content = row[1]
        write_file = open(f'{output}/{layer}.map','w')
        write_file.write(content)
        write_file.close
    return

# open db connection
conn = psycopg2.connect("host='localhost' port='5432' dbname='iso19139' user='glosis'")
cur = conn.cursor()

# run function
country_id='BT'
output=f'/home/carva014/Work/Code/FAO/GloSIS/glosis-datacube/{country_id}/output'
export_style(output, country_id, 'GSOC')
export_style(output, country_id, 'GSNM')
export_style(output, country_id, 'GSAS')
export_style(output, country_id, 'OTHER')

# close db connection
conn.commit()
cur.close()
conn.close()
