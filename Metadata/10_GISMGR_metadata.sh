#!/bin/bash

# vars
DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="iso19139"
DB_USER="sis"
BASE_URL=https://data.apps.fao.org/gismgr/api/v2
WORKSPACE="GLOSIS"
FILE_JSON="/home/carva014/Downloads/data.json"
API_KEY_CKAN=$(cat /home/carva014/Documents/Arquivo/Trabalho/FAO/API_KEY_CKAN.txt)
COUNTRY="${1}"


create_metadata() {
    # Read ID_TOKEN

    # Loop soil properties
    SQL="SELECT DISTINCT
            m.mapset_id,
            l.case,
            m.other_constraints
        FROM spatial_metadata.mapset m 
        LEFT JOIN (
                    SELECT mapset_id,
                        CASE WHEN dimension_depth IS NULL AND dimension_stats IS NULL THEN 'maps'
                             WHEN dimension_depth IS NOT NULL OR dimension_stats IS NOT NULL THEN 'mapsets'
                        END
                    FROM spatial_metadata.layer
                    GROUP BY mapset_id, dimension_depth, dimension_stats
                  ) l ON l.mapset_id = m.mapset_id
        WHERE m.country_id = '$COUNTRY'
        ORDER BY m.mapset_id"

    psql -h "$DB_HOST" -p "$DB_PORT" -d "$DB_NAME" -U "$DB_USER" -t -A -F"|" -c "$SQL" | \
    while IFS="|" read -r MAP_CODE CASE OTHER_CONSTRAINTS; do
        > "$FILE_JSON"
        echo ""
        echo $MAP_CODE

        # Create JSON file
        echo "{" >> "$FILE_JSON"
        echo "\"workspace_id\": \"${WORKSPACE}\"," >> "$FILE_JSON"
        echo "\"map_id\": \"${MAP_CODE}\"," >> "$FILE_JSON"
        echo "\"owner_org\": \"glosis\"," >> "$FILE_JSON"
        echo "\"license_code\": \"${OTHER_CONSTRAINTS}\"," >> "$FILE_JSON"
        echo "\"map_type\":\"${CASE}\"," >> "$FILE_JSON"
        echo "\"ckan_url\": \"https://data.apps.fao.org/catalog\"," >> "$FILE_JSON"
        echo "\"user_api_key\": \"${API_KEY_CKAN}\"," >> "$FILE_JSON"
        echo "\"resources\": [" >> "$FILE_JSON"

        # First, count the total number of records
        COUNT_SQL="SELECT count(*)
            FROM spatial_metadata.mapset m 
            LEFT JOIN spatial_metadata.project p ON p.country_id = m.country_id AND p.project_id = m.project_id
            LEFT JOIN spatial_metadata.proj_x_org_x_ind x ON x.country_id = p.country_id AND x.project_id = p.project_id
            LEFT JOIN spatial_metadata.individual i ON i.individual_id = x.individual_id
            WHERE m.mapset_id = '$MAP_CODE'"
        TOTAL_RECORDS=$(psql -h "$DB_HOST" -p "$DB_PORT" -d "$DB_NAME" -U "$DB_USER" -t -A -c "$COUNT_SQL")
        
        # Loop organisation and individual
        SQL="SELECT
                x.organisation_id,
                i.email,
                o.country,
                o.postal_code,
                o.city,
                o.delivery_point,
                i.individual_id,
                x.tag,
                x.role
            FROM spatial_metadata.mapset m 
            LEFT JOIN spatial_metadata.project p ON p.country_id = m.country_id AND p.project_id = m.project_id
            LEFT JOIN spatial_metadata.proj_x_org_x_ind x ON x.country_id = p.country_id AND x.project_id = p.project_id
            LEFT JOIN spatial_metadata.individual i ON i.individual_id = x.individual_id
            LEFT JOIN spatial_metadata.organisation o ON o.organisation_id = x.organisation_id
            WHERE m.mapset_id = '$MAP_CODE'"

        CURRENT_RECORD=0
        psql -h "$DB_HOST" -p "$DB_PORT" -d "$DB_NAME" -U "$DB_USER" -t -A -F"|" -c "$SQL" | \
        while IFS="|" read -r ORGANISATION_ID EMAIL COUNTRY POSTAL_CODE CITY DELIVERY_POINT INDIVIDUAL_ID TAG ROLE; do
            CURRENT_RECORD=$((CURRENT_RECORD + 1))
            echo "    {" >> "$FILE_JSON"
            echo "    \"jsonschema_body\": {" >> "$FILE_JSON"
            echo "        \"organisationName\": \"${ORGANISATION_ID}\"," >> "$FILE_JSON"
            echo "        \"role\": \"pointOfContact\"," >> "$FILE_JSON"
            echo "        \"contactInfo\": {" >> "$FILE_JSON"
            echo "        \"phone\": {" >> "$FILE_JSON"
            echo "            \"voice\": \"\"" >> "$FILE_JSON"
            echo "        }," >> "$FILE_JSON"
            echo "        \"address\": {" >> "$FILE_JSON"
            echo "            \"electronicMailAddress\": \"${EMAIL}\"," >> "$FILE_JSON"
            echo "            \"country\": \"${COUNTRY}\"," >> "$FILE_JSON"
            echo "            \"postalCode\": \"${POSTAL_CODE}\"," >> "$FILE_JSON"
            echo "            \"city\": \"${CITY}\"," >> "$FILE_JSON"
            echo "            \"deliveryPoint\": \"${DELIVERY_POINT}\"" >> "$FILE_JSON"
            echo "        }" >> "$FILE_JSON"
            echo "        }," >> "$FILE_JSON"
            echo "        \"individualName\": \"${INDIVIDUAL_ID}\"" >> "$FILE_JSON"
            echo "    }," >> "$FILE_JSON"
            echo "    \"description\": \"pointOfContact: ${INDIVIDUAL_ID}\"," >> "$FILE_JSON"
            echo "    \"jsonschema_opt\": {}," >> "$FILE_JSON"
            if [ "$ROLE" = "author" ]; then
                ROLE="resource-contact"
            elif [ "$ROLE" = "resourceProvider" ]; then
                ROLE="metadata-contact"
            fi
            echo "    \"jsonschema_type\": \"${ROLE}\"," >> "$FILE_JSON"
            echo "    \"name\": \"${ORGANISATION_ID}\"" >> "$FILE_JSON"
            
            # Add comma only if not the last record
            if [ "$CURRENT_RECORD" -lt "$TOTAL_RECORDS" ]; then
                echo "    }," >> "$FILE_JSON"
            else
                echo "    }" >> "$FILE_JSON"
            fi
        done
        echo "  ]" >> "$FILE_JSON"
        echo "}" >> "$FILE_JSON"



        # Upload metadata (does not update if exists!)
        curl -X POST \
            -H "Content-Type: application/json" \
            -d @$FILE_JSON \
            "https://data.review.fao.org/geospatial/etl/ckan/gismgr"

        if [ $? -eq 0 ]; then
            echo " Successfully processed"
        else
            echo " Failed to process"
        fi

    done
}

create_metadata
