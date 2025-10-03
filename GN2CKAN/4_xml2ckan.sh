#!/bin/bash

# This script uploads all XML files from a specified folder to CKAN

# vars
CKAN_URL="https://data.apps.fao.org/catalog/api/action/jsonschema_importer"
API_KEY_CKAN=$(cat /home/carva014/Documents/Arquivo/Trabalho/FAO/API_KEY_CKAN.txt)
OWNER_ORG="fao-paper-maps"
XML_FOLDER="/home/carva014/Downloads/FAO/Metadata/retry"
LICENSE_ID="CC-BY-4.0"
DATE=`date +%Y-%m-%d-%H-%M`
LOG_FILE="log_${DATE}.txt"
SUCCESS_COUNT=0
UPDATE_COUNT=0
ERROR_COUNT=0

echo "Import started at $(date)" | tee -a "$LOG_FILE"
echo "===========================================" | tee -a "$LOG_FILE"

import_to_ckan() {
    local file_url=$1
    local update_mode=$2
    
    curl -s -X POST "$CKAN_URL" \
      -H "Authorization: $API_KEY_CKAN" \
      -H "Content-Type: application/json" \
      -H "accept: application/xml" \
      -d "{
      \"url\": \"$file_url\",
      \"jsonschema_type\": \"iso19139\",
      \"package_update\": \"$update_mode\",
      \"from_xml\": \"True\",
      \"owner_org\": \"$OWNER_ORG\",
      \"license_id\": \"$LICENSE_ID\",
      \"import\": \"import\"
    }"
}

for XML_FILE in "$XML_FOLDER"/*.xml; do
    FILENAME=$(basename "$XML_FILE")
    echo "Processing: $FILENAME" | tee -a "$LOG_FILE"
    
    # Upload file and get URL
    RESPONSE=$(curl -s -F "file=@$XML_FILE" https://tmpfiles.org/api/v1/upload)
    PAGE_URL=$(echo "$RESPONSE" | jq -r '.data.url')
    FILE_URL=$(echo "$PAGE_URL" | sed 's|tmpfiles.org/|tmpfiles.org/dl/|')
    
    echo "Uploaded to: $FILE_URL" | tee -a "$LOG_FILE"
    
    # Try to import with package_update=False first
    RESULT=$(import_to_ckan "$FILE_URL" "False")
    
    # Check if successful
    if echo "$RESULT" | jq -e '.success == true' > /dev/null; then
        echo "✓ Successfully created new dataset" | tee -a "$LOG_FILE"
        ((SUCCESS_COUNT++))
    # Check if already exists
    elif echo "$RESULT" | grep -q "already in use"; then
        echo "⟳ Dataset exists, updating..." | tee -a "$LOG_FILE"
        
        # Retry with package_update=True
        RESULT=$(import_to_ckan "$FILE_URL" "True")
        
        if echo "$RESULT" | jq -e '.success == true' > /dev/null; then
            echo "✓ Successfully updated existing dataset" | tee -a "$LOG_FILE"
            ((UPDATE_COUNT++))
        else
            echo "✗ Error updating: $(echo "$RESULT" | jq -r '.error.message // .error')" | tee -a "$LOG_FILE"
            ((ERROR_COUNT++))
        fi
    else
        echo "✗ Error: $(echo "$RESULT" | jq -r '.error.message // .error')" | tee -a "$LOG_FILE"
        ((ERROR_COUNT++))
    fi
    
    echo "---" | tee -a "$LOG_FILE"
    sleep 2
done

echo "===========================================" | tee -a "$LOG_FILE"
echo "Import completed at $(date)" | tee -a "$LOG_FILE"
echo "Summary:" | tee -a "$LOG_FILE"
echo "  New datasets created: $SUCCESS_COUNT" | tee -a "$LOG_FILE"
echo "  Existing datasets updated: $UPDATE_COUNT" | tee -a "$LOG_FILE"
echo "  Errors: $ERROR_COUNT" | tee -a "$LOG_FILE"
echo "  Total processed: $((SUCCESS_COUNT + UPDATE_COUNT + ERROR_COUNT))" | tee -a "$LOG_FILE"


# Extract files with XML parsing errors
LOG_FILE=/home/carva014/Work/Code/FAO/GloSIS-private/GN2CKAN/import_log_${DATE}.txt
grep -B 2 "✗ Error:" $LOG_FILE | grep "Processing:" | sed 's/Processing: //' > /home/carva014/Work/Code/FAO/GloSIS-private/GN2CKAN/log_erros_${DATE}.txt

XML_FOLDER="/home/carva014/Downloads/FAO/Metadata/output"
FAILED_FILES="/home/carva014/Work/Code/FAO/GloSIS-private/GN2CKAN/log_erros_2025-10-02-20-32.txt"
RETRY_FOLDER="/home/carva014/Downloads/FAO/Metadata/retry"

# Create retry folder
mkdir -p "$RETRY_FOLDER"

echo "Copying failed files to retry folder..."
echo "Source: $XML_FOLDER"
echo "Destination: $RETRY_FOLDER"
echo ""

COPIED=0
NOT_FOUND=0

while IFS= read -r filename; do
    if [ -f "$XML_FOLDER/$filename" ]; then
        cp "$XML_FOLDER/$filename" "$RETRY_FOLDER/"
        echo "✓ Copied: $filename"
        ((COPIED++))
    else
        echo "✗ Not found: $filename"
        ((NOT_FOUND++))
    fi
done < "$FAILED_FILES"

echo ""
echo "===========================================" 
echo "Summary:"
echo "  Files copied: $COPIED"
echo "  Files not found: $NOT_FOUND"
echo ""
echo "Retry folder: $RETRY_FOLDER"


