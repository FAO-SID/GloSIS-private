#!/bin/bash

# CKAN XML Bulk Upload Script
# This script uploads all XML files from a specified folder to CKAN

# Configuration - UPDATE THESE VALUES
CKAN_URL="https://data.review.fao.org/ckanx/api/action/jsonschema_importer"
API_KEY_CKAN=$(cat /home/carva014/Documents/Arquivo/Trabalho/FAO/API_KEY_CKAN.txt)
OWNER_ORG="GLOSIS"
XML_FOLDER="/home/carva014/Downloads/FAO/Metadata/External"  # Path to folder containing XML files
LICENSE_ID="READ IT FROM DB"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to check if required tools are installed
check_dependencies() {
    print_status $YELLOW "Checking dependencies..."
    
    if ! command -v curl &> /dev/null; then
        print_status $RED "Error: curl is not installed. Please install curl to continue."
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        print_status $RED "Error: jq is not installed. Please install jq for JSON processing."
        exit 1
    fi
    
    print_status $GREEN "Dependencies check passed."
}

# Function to validate configuration
validate_config() {
    print_status $YELLOW "Validating configuration..."
    
    if [ "$API_KEY_CKAN" = "your_api_key_here" ]; then
        print_status $RED "Error: Please update API_KEY_CKAN in the script."
        exit 1
    fi
    
    if [ "$OWNER_ORG" = "your_organization_here" ]; then
        print_status $RED "Error: Please update OWNER_ORG in the script."
        exit 1
    fi
    
    if [ ! -d "$XML_FOLDER" ]; then
        print_status $RED "Error: XML folder '$XML_FOLDER' does not exist."
        exit 1
    fi
    
    print_status $GREEN "Configuration validation passed."
}

# Function to upload a single XML file
upload_xml_file() {
    local xml_file=$1
    local filename=$(basename "$xml_file")
    local temp_json="/tmp/ckan_upload_data.json"
    
    print_status $YELLOW "Processing: $filename"
    
    # Read XML content and escape it for JSON
    xml_content=$(cat "$xml_file" | jq -Rs .)
    
    # Create JSON payload
    cat > "$temp_json" << EOF
{
    "xml_content": $xml_content,
    "jsonschema_type": "iso19139",
    "package_update": "false",
    "from_xml": "true",
    "owner_org": "$OWNER_ORG",
    "license_id": "$LICENSE_ID",
    "import": "import",
    "filename": "$filename"
}
EOF
    
    # Make the API call
    response=$(curl -s -w "\n%{http_code}" \
        -X POST \
        -H "Content-Type: application/json" \
        -H "Authorization: $API_KEY_CKAN" \
        -H "Accept: application/xml" \
        -d @"$temp_json" \
        "$CKAN_URL")
    
    # Extract HTTP status code and response body
    http_code=$(echo "$response" | tail -n1)
    response_body=$(echo "$response" | head -n -1)
    
    # Clean up temp file
    rm -f "$temp_json"
    
    # Check response
    if [ "$http_code" = "200" ]; then
        print_status $GREEN "✓ Successfully uploaded: $filename"
        echo "  Response: $response_body" | head -c 100
        echo "..."
    else
        print_status $RED "✗ Failed to upload: $filename (HTTP $http_code)"
        echo "  Response: $response_body"
    fi
    
    echo ""
}

# Function to upload XML files via URL (alternative method)
upload_xml_via_url() {
    local xml_file=$1
    local filename=$(basename "$xml_file")
    
    print_status $YELLOW "Processing via URL method: $filename"
    
    # Note: This method assumes you have a way to serve your XML files via HTTP
    # You would need to modify this section based on your setup
    
    local xml_url="http://your-server.com/xml/$filename"  # UPDATE THIS
    
    local json_data=$(cat << EOF
{
    "url": "$xml_url",
    "jsonschema_type": "iso19139",
    "package_update": "false",
    "from_xml": "true",
    "owner_org": "$OWNER_ORG",
    "license_id": "$LICENSE_ID",
    "import": "import"
}
EOF
)
    
    response=$(curl -s -w "\n%{http_code}" \
        -X POST \
        -H "Content-Type: application/json" \
        -H "Authorization: $API_KEY_CKAN" \
        -H "Accept: application/xml" \
        -d "$json_data" \
        "$CKAN_URL")
    
    http_code=$(echo "$response" | tail -n1)
    response_body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" = "200" ]; then
        print_status $GREEN "✓ Successfully uploaded: $filename"
    else
        print_status $RED "✗ Failed to upload: $filename (HTTP $http_code)"
        echo "  Response: $response_body"
    fi
    
    echo ""
}

# Main execution
main() {
    print_status $YELLOW "=== CKAN XML Bulk Upload Script ==="
    echo ""
    
    # Check dependencies and configuration
    check_dependencies
    validate_config
    
    # Count XML files
    xml_count=$(find "$XML_FOLDER" -name "*.xml" -type f | wc -l)
    
    if [ $xml_count -eq 0 ]; then
        print_status $RED "No XML files found in '$XML_FOLDER'"
        exit 1
    fi
    
    print_status $GREEN "Found $xml_count XML files to upload."
    echo ""
    
    # Ask for confirmation
    read -p "Do you want to proceed with uploading $xml_count files? (y/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status $YELLOW "Upload cancelled."
        exit 0
    fi
    
    echo ""
    print_status $YELLOW "Starting upload process..."
    echo ""
    
    # Initialize counters
    success_count=0
    failure_count=0
    
    # Process each XML file
    for xml_file in "$XML_FOLDER"/*.xml; do
        if [ -f "$xml_file" ]; then
            upload_xml_file "$xml_file"
            
            # Check if upload was successful (simple check based on output)
            if [ $? -eq 0 ]; then
                ((success_count++))
            else
                ((failure_count++))
            fi
            
            # Add a small delay to avoid overwhelming the server
            sleep 1
        fi
    done
    
    # Summary
    echo ""
    print_status $YELLOW "=== Upload Summary ==="
    print_status $GREEN "Successful uploads: $success_count"
    print_status $RED "Failed uploads: $failure_count"
    print_status $YELLOW "Total processed: $xml_count"
    echo ""
    
    if [ $failure_count -gt 0 ]; then
        print_status $YELLOW "Some uploads failed. Please check the output above for details."
    else
        print_status $GREEN "All uploads completed successfully!"
    fi
}

# Show usage information
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -f, --folder   Specify XML folder path (default: ./xml_files)"
    echo "  -o, --org      Specify owner organization"
    echo "  -k, --key      Specify CKAN API key"
    echo ""
    echo "Example:"
    echo "  $0 -f /path/to/xml/files -o my-org -k your-api-key"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -f|--folder)
            XML_FOLDER="$2"
            shift 2
            ;;
        -o|--org)
            OWNER_ORG="$2"
            shift 2
            ;;
        -k|--key)
            API_KEY_CKAN="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Run main function
main