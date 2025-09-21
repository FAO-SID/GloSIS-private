#!/bin/bash

# CKAN XML Bulk Upload Script
# This script uploads all XML files from a specified folder to CKAN

# Configuration - UPDATE THESE VALUES
CKAN_URL="https://data.review.fao.org/ckanx/api/action/jsonschema_importer"
API_KEY_CKAN=$(cat /home/carva014/Documents/Arquivo/Trabalho/FAO/API_KEY_CKAN.txt)
OWNER_ORG="GLOSIS"
XML_FOLDER="/home/carva014/Downloads/FAO/Metadata/External"  # Path to folder containing XML files
LICENSE_ID="CC-BY-NC-SA-4.0"

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
    
    if ! command -v python3 &> /dev/null; then
        print_status $RED "Error: python3 is not installed. Please install python3 for local HTTP server."
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

# Function to create a temporary HTTP server for XML files (if needed)
start_temp_server() {
    local port=8000
    local server_pid_file="/tmp/temp_xml_server.pid"
    
    print_status $YELLOW "Starting temporary HTTP server on port $port..."
    
    # Start a simple HTTP server in the XML directory
    cd "$XML_FOLDER"
    python3 -m http.server $port > /tmp/temp_server.log 2>&1 &
    echo $! > "$server_pid_file"
    
    # Wait a moment for server to start
    sleep 2
    
    # Test if server is running
    if curl -s "http://localhost:$port" > /dev/null; then
        print_status $GREEN "Temporary server started successfully"
        echo "http://localhost:$port"
    else
        print_status $RED "Failed to start temporary server"
        return 1
    fi
}

# Function to stop temporary HTTP server
stop_temp_server() {
    local server_pid_file="/tmp/temp_xml_server.pid"
    
    if [ -f "$server_pid_file" ]; then
        local pid=$(cat "$server_pid_file")
        if kill "$pid" 2>/dev/null; then
            print_status $YELLOW "Stopped temporary HTTP server"
        fi
        rm -f "$server_pid_file"
        rm -f "/tmp/temp_server.log"
    fi
}

# Function to upload a single XML file using the original method
upload_xml_file() {
    local xml_file=$1
    local filename=$(basename "$xml_file")
    local temp_json="/tmp/ckan_upload_data.json"
    
    print_status $YELLOW "Processing: $filename"
    
    # Extract UUID from filename if it matches the pattern
    local uuid=$(echo "$filename" | grep -o '[0-9a-f]\{8\}-[0-9a-f]\{4\}-[0-9a-f]\{4\}-[0-9a-f]\{4\}-[0-9a-f]\{12\}' | head -1)
    
    if [ -n "$uuid" ]; then
        # Use the original URL-based method if we can extract UUID
        upload_xml_via_original_method "$uuid" "$filename"
    else
        # Use local server method
        upload_xml_via_local_server "$filename"
    fi
}

# Function to upload using original FAO method (if UUID available)
upload_xml_via_original_method() {
    local uuid=$1
    local filename=$2
    local temp_json="/tmp/ckan_upload_data.json"
    
    print_status $YELLOW "Using original FAO URL method for UUID: $uuid"
    
    # Create JSON payload matching the original instructions exactly
    cat > "$temp_json" << EOF
{
    "url": "https://data.apps.fao.org/map/catalog/srv/api/records/$uuid/formatters/xml?approved=true",
    "jsonschema_type": "iso19139",
    "package_update": "false",
    "from_xml": "true",
    "owner_org": "$OWNER_ORG",
    "license_id": "$LICENSE_ID",
    "import": "import"
}
EOF
    
    # Make the API call exactly as in original instructions
    response=$(curl -s -w "\n%{http_code}" \
        -X POST \
        -H "Content-Type: application/json" \
        -H "Accept: application/xml" \
        -H "Authorization: $API_KEY_CKAN" \
        -d @"$temp_json" \
        "$CKAN_URL")
    
    # Extract HTTP status code and response body
    http_code=$(echo "$response" | tail -n1)
    response_body=$(echo "$response" | head -n -1)
    
    # Clean up temp file
    rm -f "$temp_json"
    
    # Check response
    if [ "$http_code" = "200" ]; then
        # Check if response contains success indicators
        if echo "$response_body" | grep -q '"success": *true' || echo "$response_body" | grep -q '"result"'; then
            print_status $GREEN "✓ Successfully uploaded: $filename"
            echo "  Response: $response_body" | head -c 200
            echo "..."
            return 0
        else
            print_status $RED "✗ Upload may have failed: $filename"
            echo "  Response: $response_body"
            return 1
        fi
    else
        print_status $RED "✗ Failed to upload: $filename (HTTP $http_code)"
        echo "  Response: $response_body"
        return 1
    fi
}

# Function to upload using local server
upload_xml_via_local_server() {
    local filename=$1
    local temp_json="/tmp/ckan_upload_data.json"
    local xml_url="http://localhost:8000/$filename"
    
    print_status $YELLOW "Using local server method for: $filename"
    
    # Create JSON payload
    cat > "$temp_json" << EOF
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
    
    # Make the API call
    response=$(curl -s -w "\n%{http_code}" \
        -X POST \
        -H "Content-Type: application/json" \
        -H "Accept: application/xml" \
        -H "Authorization: $API_KEY_CKAN" \
        -d @"$temp_json" \
        "$CKAN_URL")
    
    # Extract HTTP status code and response body
    http_code=$(echo "$response" | tail -n1)
    response_body=$(echo "$response" | head -n -1)
    
    # Clean up temp file
    rm -f "$temp_json"
    
    # Check response
    if [ "$http_code" = "200" ]; then
        # Check if response contains success indicators
        if echo "$response_body" | grep -q '"success": *true' || echo "$response_body" | grep -q '"result"'; then
            print_status $GREEN "✓ Successfully uploaded: $filename"
            echo "  Response: $response_body" | head -c 200
            echo "..."
            return 0
        else
            print_status $RED "✗ Upload may have failed: $filename"
            echo "  Response: $response_body"
            return 1
        fi
    else
        print_status $RED "✗ Failed to upload: $filename (HTTP $http_code)"
        echo "  Response: $response_body"
        return 1
    fi
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
    
    # Check if any files have UUIDs (can use original method)
    uuid_files=0
    for xml_file in "$XML_FOLDER"/*.xml; do
        if [ -f "$xml_file" ]; then
            filename=$(basename "$xml_file")
            if echo "$filename" | grep -q '[0-9a-f]\{8\}-[0-9a-f]\{4\}-[0-9a-f]\{4\}-[0-9a-f]\{4\}-[0-9a-f]\{12\}'; then
                ((uuid_files++))
            fi
        fi
    done
    
    # Start local server if needed
    local server_url=""
    if [ $uuid_files -lt $xml_count ]; then
        print_status $YELLOW "$((xml_count - uuid_files)) files don't have UUIDs, starting local HTTP server..."
        server_url=$(start_temp_server)
        if [ $? -ne 0 ]; then
            print_status $RED "Failed to start local server. Cannot proceed with non-UUID files."
            exit 1
        fi
    fi
    
    # Process each XML file
    for xml_file in "$XML_FOLDER"/*.xml; do
        if [ -f "$xml_file" ]; then
            upload_xml_file "$xml_file"
            
            # Check if upload was successful
            if [ $? -eq 0 ]; then
                ((success_count++))
            else
                ((failure_count++))
            fi
            
            # Add a small delay to avoid overwhelming the server
            sleep 2
        fi
    done
    
    # Stop local server if it was started
    if [ -n "$server_url" ]; then
        stop_temp_server
    fi
    
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


# API_KEY_CKAN=$(cat /home/carva014/Documents/Arquivo/Trabalho/FAO/API_KEY_CKAN.txt)

# # Check your user details
# curl -H "Authorization: $API_KEY_CKAN" "https://data.review.fao.org/ckanx/api/3/action/user_show"
# # {"help": "https://data.review.fao.org/ckanx/api/3/action/help_show?name=user_show", "success": false, "                       error": {"message": "Not found", "__type": "Not Found Error"}}(base)

# # Check organization membership
# curl -H "Authorization: $API_KEY_CKAN" "https://data.review.fao.org/ckanx/api/3/action/member_list?id=GLOSIS&object_type=user"
# # {"help": "https://data.review.fao.org/ckanx/api/3/action/help_show?name=organization_list_for_user", "success": true, "result": []}(base)

# # List organizations you belong to
# curl -H "Authorization: $API_KEY_CKAN" "https://data.review.fao.org/ckanx/api/3/action/organization_list_for_user"
# # {"help": "https://data.review.fao.org/ckanx/api/3/action/help_show?name=organization_list_for_user", "success": true, "result": []}(base)


