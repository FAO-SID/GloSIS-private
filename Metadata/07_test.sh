#!/bin/bash

# vars
DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="iso19139"
DB_USER="sis"
FILE_JSON="/home/carva014/Downloads/data.json"

update_map() {
    # Use a different delimiter that's less likely to appear in the data
    # Or escape newlines in the abstract field
    psql -h "$DB_HOST" -p "$DB_PORT" -d "$DB_NAME" -U "$DB_USER" -t -A -F"|" -c \
    "SELECT mapset_id,
     REPLACE(REPLACE(abstract, E'\n', '\\n'), E'\r', '\\r') as abstract,
     unit_of_measure_id
     FROM spatial_metadata.mapset
     ORDER BY mapset_id" | \
    while IFS="|" read -r MAPSET ABSTRACT UNIT; do
        > "$FILE_JSON"
        echo $MAPSET, $UNIT
        
        # Properly escape for JSON: quotes and keep newlines as \n
        ABSTRACT_CLEAN=$(echo "$ABSTRACT" | sed 's/"/\\"/g')
        
        # Create JSON file
        echo "{" >> "$FILE_JSON"
        echo " \"mapset\": \"${MAPSET}\"," >> "$FILE_JSON"
        echo " \"abstract\": \"${ABSTRACT_CLEAN}\"," >> "$FILE_JSON"
        echo " \"unit\": \"${UNIT}\" " >> "$FILE_JSON"
        echo "}" >> "$FILE_JSON"
    done
}

update_map
