#!/bin/bash

# Test the updated VS Code handler with curl-based template downloading
cd /Users/jdelon02/Projects/AiOps/projectai

# Set up test environment variables
export PRIMARY_PROJECT_TYPE="drupal"
export ADDITIONAL_PROJECT_TYPES=("php" "mysql")
export ALL_PROJECT_TYPES=("$PRIMARY_PROJECT_TYPE" "${ADDITIONAL_PROJECT_TYPES[@]}")
export FULL_PATH="/tmp/vscode-curl-test"
export DIRECTORY="test-project"
export BASE_URL="https://raw.githubusercontent.com/jdelon02/agent-os/main"

# Create test directory
mkdir -p "$FULL_PATH"

# Define check_curl function (mock - simulating different scenarios)
check_curl() {
    local url="$1"
    echo "Mock check_curl called with: $url"
    
    # Simulate that .vscode directory doesn't exist (return false)
    if [[ "$url" == *".vscode/"* ]]; then
        return 1
    fi
    
    # For other URLs, return true
    return 0
}

# Source the VS Code handler
source "./ide_specific/vscode.sh"

# Test the function
echo "Testing updated VS Code handler with curl-based approach..."
create_vscode_instruction_file "drupal (+ php mysql)"

echo ""
echo "Files created:"
find "$FULL_PATH" -type f 2>/dev/null || echo "No files found"

echo ""
echo "Directory structure:"
find "$FULL_PATH" -type d 2>/dev/null || echo "No directories found"

# Clean up
rm -rf "$FULL_PATH"
