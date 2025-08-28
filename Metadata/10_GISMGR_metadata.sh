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

create_metadata() {
    # Read ID_TOKEN
    source "$API_KEY_CKAN"

    # Loop soil properties
    psql -h "$DB_HOST" -p "$DB_PORT" -d "$DB_NAME" -U "$DB_USER" -t -A -F"|" -c \
    "SELECT DISTINCT
        m.file_identifier,
        m.mapset_id,
        l.case,
        v.organisation_id,
        i.email,
        o.country,
        o.postal_code,
        o.city,
        o.delivery_point,
        i.individual_id
    FROM spatial_metadata.mapset m 
    LEFT JOIN spatial_metadata.ver_x_org_x_ind v ON v.mapset_id = m.mapset_id
    LEFT JOIN spatial_metadata.individual i ON i.individual_id = v.individual_id
    LEFT JOIN spatial_metadata.organisation o ON o.organisation_id = v.organisation_id
    LEFT JOIN (
                SELECT mapset_id, 
                    CASE count(*) WHEN 1 THEN 'maps'
                                  WHEN 2 THEN 'mapsets'
                    END
                FROM spatial_metadata.layer
                GROUP BY mapset_id
    ) l ON l.mapset_id = m.mapset_id
    WHERE m.mapset_id = 'PH-GSAS-SALT-2020'
    ORDER BY m.mapset_id, v.organisation_id" | \
    while IFS="|" read -r FILE_IDENTIFIER MAP_CODE CASE ORGANISATION_ID EMAIL COUNTRY POSTAL_CODE CITY DELIVERY_POINT INDIVIDUAL_ID; do
        > "$FILE_JSON"
        echo ""
        echo $MAP_CODE

        # Create JSON file
        echo "{" >> "$FILE_JSON"
        echo "\"workspace_id\": \"${WORKSPACE}\"," >> "$FILE_JSON"
        echo "\"map_id\": \"${MAP_CODE}\"," >> "$FILE_JSON"
        echo "\"owner_org\": \"glosis\"," >> "$FILE_JSON"
        echo "\"map_type\":\"${CASE}\"," >> "$FILE_JSON"
        echo "\"ckan_url\": \"https://data.apps.fao.org/catalog\"," >> "$FILE_JSON"
        echo "\"user_api_key\": \"${API_KEY_CKAN}\"," >> "$FILE_JSON"
        echo "\"resources\": [" >> "$FILE_JSON"
        echo "    {" >> "$FILE_JSON"
        echo "    \"jsonschema_body\": {" >> "$FILE_JSON"
        echo "        \"organisationName\": \"${ORGANISATION_ID}\"," >> "$FILE_JSON"
        echo "        \"role\": \"pointOfContact\"," >> "$FILE_JSON"
        echo "        \"contactInfo\": {" >> "$FILE_JSON"
        echo "       \"phone\": {" >> "$FILE_JSON"
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
        echo "    \"description\": \"pointOfContact: ${ORGANISATION_ID}\"," >> "$FILE_JSON"
        echo "    \"jsonschema_opt\": {}," >> "$FILE_JSON"
        echo "    \"jsonschema_type\": \"metadata-contact\"," >> "$FILE_JSON"
        echo "    \"name\": \"${ORGANISATION_ID}\"" >> "$FILE_JSON"
        echo "    }" >> "$FILE_JSON"
        echo "]" >> "$FILE_JSON"
        echo "}" >> "$FILE_JSON"

        # Upload or Update metadata
        curl -X POST \
            -H "Content-Type: application/json" \
            -d @$FILE_JSON \
            "https://data.review.fao.org/geospatial/etl/ckan/gismgr"

        if [ $? -eq 0 ]; then
            echo "Successfully processed mapet: $MAP_CODE"
        else
            echo "Failed to process mapet: $MAP_CODE"
        fi

    done
}

create_metadata
