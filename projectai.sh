#!/bin/bash

# projectai.sh
# Description: Main script for project AI operations that extends agent-os functionality.
# This script initializes a project by copying templates from a GitHub repository,
# customizing them based on user input, and setting up the project structure.
# Created: July 24, 2025
# Usage: projectai <project_type>

# Exit on error
set -e

# Check if we have the required arguments    if [ ! -s "$ide_script" ]; then
        echo "  ⬇️ Fetching IDE script from GitHub..."
        temp_script=$(mktemp) || {
            handle_error "Failed to create temporary file"
            return 1
        }
        
        # First check if the GitHub URL is accessible
        if ! curl --output /dev/null --silent --head --fail "$ide_script_url"; {
            rm -f "$temp_script"
            handle_error "IDE script not found at $ide_script_url"
            return 1
        }
        
        # Download the script
        if ! curl -s --fail -o "$temp_script" "$ide_script_url"; {
            rm -f "$temp_script"
            handle_error "Failed to download IDE script from $ide_script_url"
            return 1
        }
    echo "Error: Missing project type argument(s)"
    echo "Usage: projectai <primary_project_type> [additional_project_types...]"
    echo "Example: projectai drupal php mysql css javascript lando"
    exit 1
fi

# Handle help flag
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "ProjectAI - AI-assisted project initialization with Agent OS"
    echo ""
    echo "Usage: projectai <primary_project_type> [additional_project_types...]"
    echo ""
    echo "Parameters:"
    echo "  primary_project_type     Main technology/framework (required)"
    echo "  additional_project_types Supporting technologies (optional)"
    echo ""
    echo "Note: Project types are automatically converted to lowercase for consistency."
    echo ""
    echo "Examples:"
    echo "  projectai drupal"
    echo "  projectai drupal php mysql css javascript lando"
    echo "  projectai react typescript tailwind"
    echo "  projectai python fastapi postgresql"
    echo ""
    echo "Prerequisites:"
    echo "  - Agent OS must be installed first"
    echo "  - Run: curl -sSL https://raw.githubusercontent.com/jdelon02/agent-os/main/setup.sh | bash"
    echo ""
    echo "For more information: https://github.com/jdelon02/projectai"
    exit 0
fi

# Function to check if we have permission to create symlinks in a directory
check_symlink_permissions() {
    local dir="$1"
    
    # Check if directory exists
    if [ ! -d "$dir" ]; then
        echo "❌ Error: Directory $dir does not exist"
        return 1
    fi
    
    # Try to create a test symlink
    local test_link="${dir}/.test_symlink"
    if ! ln -sf "$dir" "$test_link" 2>/dev/null; then
        echo "❌ Error: No permission to create symlinks in $dir"
        return 1
    fi
    
    # Clean up test symlink
    rm -f "$test_link"
    return 0
}

# Function to validate project types against known types
validate_project_types() {
    local types=("$@")
    local valid_types=()
    
    # Get list of valid project types from .agent-os directory
    for type in "${types[@]}"; do
        type_lower=$(echo "$type" | tr '[:upper:]' '[:lower:]')
        if [ ! -d "${HOME}/.agent-os/${type_lower}" ]; then
            echo "⚠️ Warning: Invalid project type '${type}'"
            continue
        fi
        valid_types+=("$type_lower")
    done
    
    # Check if we have any valid types
    if [ ${#valid_types[@]} -eq 0 ]; then
        echo "❌ Error: No valid project types provided"
        return 1
    fi
    
    echo "${valid_types[@]}"
    return 0
}

# Function to check if source directories exist in .agent-os
check_source_directories() {
    local dirs=("$@")
    local missing=()
    
    for dir in "${dirs[@]}"; do
        if [ ! -d "${HOME}/.agent-os/${dir}" ]; then
            missing+=("$dir")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo "❌ Error: Missing required .agent-os directories: ${missing[*]}"
        return 1
    fi
    
    return 0
}

# Function to safely create symlink with checks
safe_create_symlink() {
    local source="$1"
    local target="$2"
    
    # Check if source exists
    if [ ! -e "$source" ]; then
        echo "❌ Error: Source path does not exist: $source"
        return 1
    fi
    
    # Check if target already exists
    if [ -e "$target" ] || [ -L "$target" ]; then
        echo "⚠️ Warning: Target already exists, removing: $target"
        rm -f "$target"
    fi
    
    # Create symlink
    if ! ln -sf "$source" "$target"; then
        echo "❌ Error: Failed to create symlink from $source to $target"
        return 1
    fi
    
    return 0
}

# Function to create global symlinks for Agent OS directories
create_global_symlinks() {
    local project_dir="$1"
    local global_dirs=("standards" "instructions" "commands" "chatmodes" "prompts")
    
    echo "🔗 Creating global symlinks for Agent OS directories..."
    
    # Check directory permissions
    if ! check_symlink_permissions "${project_dir}"; then
        return 1
    fi
    
    # Check source directories exist
    if ! check_source_directories "${global_dirs[@]}"; then
        return 1
    fi
    
    # Create reference-docs directory in project
    mkdir -p "${project_dir}/reference-docs"
    
    # Create symlinks for global directories
    for dir in "${global_dirs[@]}"; do
        if [ -d "${HOME}/.agent-os/${dir}" ]; then
            echo "  ✓ Linking ${dir}"
            if safe_create_symlink "${HOME}/.agent-os/${dir}" "${project_dir}/reference-docs/${dir}"; then
                echo "    ✓ Successfully linked ${dir}"
            else
                echo "    ❌ Failed to link ${dir}"
            fi
        else
            echo "⚠️  Warning: ${HOME}/.agent-os/${dir} not found"
        fi
    done
}

# Function to create symlinks for project-specific Agent OS directories
create_project_type_symlinks() {
    local project_dir="$1"
    shift
    local project_types=("$@")
    
    echo "🔗 Creating project-specific symlinks..."
    
    # Create reference-docs directory for project type symlinks
    mkdir -p "${project_dir}/reference-docs"
    
    # Validate project types
    local valid_types
    if ! valid_types=$(validate_project_types "${project_types[@]}"); then
        return 1
    fi
    read -ra valid_types_array <<< "$valid_types"
    
    # Check directory permissions
    if ! check_symlink_permissions "${project_dir}"; then
        return 1
    fi
    
    # Create symlinks for each project type
    for type in "${valid_types_array[@]}"; do
        if [ -d "${HOME}/.agent-os/${type}" ]; then
            echo "  ✓ Linking ${type} project type"
            if safe_create_symlink "${HOME}/.agent-os/${type}" "${project_dir}/reference-docs/${type}"; then
                echo "    ✓ Successfully linked ${type}"
            else
                echo "    ❌ Failed to link ${type}"
                missing_types+=("$type")
            fi
        else
            echo "⚠️  Warning: ${HOME}/.agent-os/${type} not found"
            missing_types+=("$type")
        fi
    done
    
    # Report missing project types if any
    if [ ${#missing_types[@]} -gt 0 ]; then
        echo ""
        echo "ℹ️  Some project types were not found in Agent OS:"
        printf "   - %s\n" "${missing_types[@]}"
        echo ""
        echo "💡 To install missing types, run:"
        echo "   curl -sSL https://raw.githubusercontent.com/jdelon02/agent-os/main/setup.sh | bash -s -- --dirs \"${missing_types[*]}\""
        echo ""
    fi
}

# Parse input and set variables only if they don't exist
if [ -z "${PRIMARY_PROJECT_TYPE+x}" ] || [ -z "${ADDITIONAL_PROJECT_TYPES+x}" ]; then
    # Parse comma-separated input
    IFS=',' read -r -a ALL_TYPES <<< "$1"
    
    # Set primary type if not set
    if [ -z "${PRIMARY_PROJECT_TYPE+x}" ]; then
        PRIMARY_PROJECT_TYPE=$(echo "${ALL_TYPES[0]}" | tr '[:upper:]' '[:lower:]')
    fi
    
    # Set additional types if not set
    if [ -z "${ADDITIONAL_PROJECT_TYPES+x}" ]; then
        ADDITIONAL_PROJECT_TYPES=()
        for ((i=1; i<${#ALL_TYPES[@]}; i++)); do
            ADDITIONAL_PROJECT_TYPES+=("$(echo "${ALL_TYPES[$i]}" | tr '[:upper:]' '[:lower:]')")
        done
    fi
fi

# Set derived variables only if they don't exist
if [ -z "${ALL_PROJECT_TYPES+x}" ]; then
    ALL_PROJECT_TYPES=("$PRIMARY_PROJECT_TYPE" "${ADDITIONAL_PROJECT_TYPES[@]}")
fi

if [ -z "${FULL_PATH+x}" ]; then
    FULL_PATH="$(pwd)"
fi

if [ -z "${DIRECTORY+x}" ]; then
    DIRECTORY=$(basename "$FULL_PATH")
fi

# Base URL for raw GitHub content
BASE_URL="https://raw.githubusercontent.com/jdelon02/projectai/main"

# Get the directory where this script is located and ensure it's the project root
SCRIPT_DIR="$FULL_PATH"

# Create necessary project directories
mkdir -p "$SCRIPT_DIR/ide_specific"

# Function to prompt user for IDE selection
prompt_ide_selection() {
    echo ""
    echo "🤖 Which AI coding tool are you using?"
    echo ""
    echo "1) Claude Code (Anthropic's desktop app)"
    echo "   - Uses CLAUDE.md files for instructions"
    echo "   - Supports /plan-product, /create-spec, /execute-task commands"
    echo ""
    echo "2) VS Code with GitHub Copilot"
    echo "   - Uses .github/instructions/main.instructions.md files"
    echo "   - Works with GitHub Copilot and other extensions"
    echo ""
    echo "3) Cursor IDE"
    echo "   - Uses .cursorrules files for configuration"
    echo "   - Integrated AI-powered code editor"
    echo ""
    
    while true; do
        echo -n "Enter your choice (1-3): "
        read choice < /dev/tty
        case $choice in
            1)
                IDE_TYPE="claude"
                echo "✓ Selected: Claude Code"
                break
                ;;
            2)
                IDE_TYPE="vscode"
                echo "✓ Selected: VS Code with GitHub Copilot"
                break
                ;;
            3)
                IDE_TYPE="cursor"
                echo "✓ Selected: Cursor IDE"
                break
                ;;
            *)
                echo "❌ Invalid choice '$choice'. Please enter 1, 2, or 3."
                ;;
        esac
    done
    echo ""
}

# Function to validate Agent OS directories exist
validate_agent_os_directories() {
    echo "🔍 Validating Agent OS installation and project types..."
    
    # Check if ~/.agent-os directory exists
    if [ ! -d "$HOME/.agent-os" ]; then
        handle_error "Agent OS not found at ~/.agent-os. Please install Agent OS first using: curl -sSL https://raw.githubusercontent.com/jdelon02/agent-os/main/setup.sh | bash"
        return 1
    fi
    
    local valid_types=()
    local invalid_types=()
    
    # Check each project type
    for project_type in "${ALL_PROJECT_TYPES[@]}"; do
        if [ -d "$HOME/.agent-os/$project_type" ]; then
            valid_types+=("$project_type")
            echo "  ✓ Found ~/.agent-os/$project_type"
        else
            invalid_types+=("$project_type")
            echo "  ❌ Missing ~/.agent-os/$project_type"
        fi
    done
    
    # Report results
    if [ ${#invalid_types[@]} -gt 0 ]; then
        echo ""
        echo "⚠️  Warning: The following project types are not installed in Agent OS:"
        for invalid_type in "${invalid_types[@]}"; do
            echo "    - $invalid_type"
        done
        echo ""
        echo "💡 To add missing project types, run:"
        echo "    curl -sSL https://raw.githubusercontent.com/jdelon02/agent-os/main/setup.sh | bash -s -- --dirs \"$(IFS=,; echo "${invalid_types[*]}")\""
        echo ""
        
        # Ask user if they want to continue
        while true; do
            echo -n "Continue with available project types only? (y/n): "
            read continue_choice < /dev/tty
            case $continue_choice in
                [Yy]* | [Yy][Ee][Ss]*)
                    # Update arrays to only include valid types
                    ALL_PROJECT_TYPES=("${valid_types[@]}")
                    if [ ${#ALL_PROJECT_TYPES[@]} -eq 0 ]; then
                        handle_error "No valid project types found. Cannot continue."
                        return 1
                    fi
                    PRIMARY_PROJECT_TYPE="${ALL_PROJECT_TYPES[0]}"
                    # Update ADDITIONAL_PROJECT_TYPES array
                    ADDITIONAL_PROJECT_TYPES=("${ALL_PROJECT_TYPES[@]:1}")
                    echo "✓ Continuing with: ${ALL_PROJECT_TYPES[*]}"
                    break
                    ;;
                [Nn]* | [Nn][Oo]*)
                    handle_error "User chose not to continue with missing project types."
                    return 1
                    ;;
                "")
                    echo "❌ Please enter y or n."
                    ;;
                *)
                    echo "❌ Invalid input '$continue_choice'. Please enter y or n."
                    ;;
            esac
        done
    else
        echo "✓ All project types are available in Agent OS"
    fi
    
    echo ""
    return 0
}

# Function to handle errors gracefully
handle_error() {
    local error_message="$1"
    echo "❌ Error: $error_message"
    return 1
}

# Function to create IDE-specific instruction file
create_instruction_file() {
    echo "📝 Creating IDE-specific instruction file..."
    
    # Set up local paths and GitHub URLs
    local ide_script="$SCRIPT_DIR/ide_specific/${IDE_TYPE}.sh"
    local ide_script_url="${BASE_URL}/ide_specific/${IDE_TYPE}.sh"
    local temp_script
    
    # Try to create ide_specific directory if it doesn't exist
    mkdir -p "$SCRIPT_DIR/ide_specific"
    
    # If local script doesn't exist, try to fetch from GitHub
    if [ ! -f "$ide_script" ]; then
        echo "  ⬇️ Fetching IDE script from GitHub..."
        temp_script=$(mktemp) || {
            handle_error "Failed to create temporary file"
            return 1
        }
        
        # Download the script
        if ! curl -s --fail -o "$temp_script" "$ide_script_url"; then
            rm -f "$temp_script"
            handle_error "Failed to download IDE script from $ide_script_url"
            return 1
        fi
        
        # Move to final location
        if ! mv "$temp_script" "$ide_script"; then
            rm -f "$temp_script"
            handle_error "Failed to install IDE script to $ide_script"
            return 1
        fi
        
        # Make executable
        chmod +x "$ide_script"
    fi
    
    # Export variables needed by IDE scripts
    export PRIMARY_PROJECT_TYPE
    export ADDITIONAL_PROJECT_TYPES
    export ALL_PROJECT_TYPES
    export FULL_PATH
    export DIRECTORY
    export BASE_URL
    export SCRIPT_DIR
    
    # Source the IDE-specific script and run its setup function
    source "$ide_script"
    
    # Execute IDE-specific setup
    if ! ide_setup; then
        handle_error "IDE setup failed"
        return 1
    fi
    
    return 0
}

# Function to check if curl request succeeded
check_curl() {
    local url="$1"
    local description="$2"
    if ! curl --output /dev/null --silent --head --fail "$url"; then
        handle_error "Unable to access $description at $url"
        return 1
    fi
    return 0
}


# Function to copy templates and perform replacements
copy_and_replace() {
    echo "🚀 Fetching project templates from GitHub..."
    
    # Create temporary directory for downloads
    local temp_dir=$(mktemp -d) || {
        handle_error "Failed to create temporary directory"
        return 1
    }
    trap 'rm -rf "$temp_dir"' EXIT
    
    # Check GitHub connectivity first
    if ! check_curl "${BASE_URL}" "GitHub repository"; then
        handle_error "Cannot connect to GitHub. Please check your internet connection"
        return 1
    fi
    
    # Dynamically fetch list of directories from GitHub
    echo "📂 Fetching template directory structure..."
    local template_dirs
    template_dirs=($(curl -s --fail "${BASE_URL}/project_templates/" 2>/dev/null | grep -o 'href="[^"]*/"' | cut -d'"' -f2 | sed 's#/$##')) || {
        handle_error "Failed to fetch template directory structure"
        return 1
    }
    
    if [ ${#template_dirs[@]} -eq 0 ]; then
        handle_error "No template directories found at ${BASE_URL}/project_templates/"
        return 1
    fi
    
    echo "✓ Found ${#template_dirs[@]} template directories"
    local success_count=0
    local error_count=0
    
    for template_dir in "${template_dirs[@]}"; do
        echo "📁 Processing ${template_dir}..."
        local target_dir="$FULL_PATH/${template_dir}"
        
        # Check if directory already exists
        if [ -d "$target_dir" ]; then
            echo "  ⚠️  Directory ${template_dir} already exists, skipping..."
            continue
        fi
        
        # Create directory with error checking
        if ! mkdir -p "$target_dir"; then
            echo "  ⚠️  Failed to create directory ${template_dir}, skipping..."
            ((error_count++))
            continue
        fi
        
        # Attempt to fetch and process template files
        if check_curl "${BASE_URL}/project_templates/${template_dir}/" "template directory ${template_dir}"; then
            local files
            # Look for markdown and configuration files
            files=$(curl -s "${BASE_URL}/project_templates/${template_dir}/" 2>/dev/null | grep -o '"[^"]*\.\(md\|json\|yaml\|yml\)"' | tr -d '"') || {
                echo "  ⚠️  Failed to list files in ${template_dir}, skipping..."
                ((error_count++))
                continue
            }
            
            local file_success=0
            for template_file in $files; do
                local target_file="$template_file"
                local target_path="${target_dir}/${target_file}"
                
                echo "  ⬇️  Downloading ${template_file}..."
                if curl -s --fail -o "$target_path" "${BASE_URL}/project_templates/${template_dir}/${template_file}" 2>/dev/null; then
                    if [ -f "$target_path" ]; then
                        # Create replacement strings for multiple project types
                        local additional_types_str="${ADDITIONAL_PROJECT_TYPES[*]}"
                        local all_types_str="${ALL_PROJECT_TYPES[*]}"
                        
                        if sed -i '' \
                            -e "s/<PROJECTTYPE>/$PRIMARY_PROJECT_TYPE/g" \
                            -e "s/<DIRECTORY_NAME>/$DIRECTORY/g" \
                            -e "s/<ADDITIONAL_TYPES>/$additional_types_str/g" \
                            -e "s/<ALL_TYPES>/$all_types_str/g" \
                            "$target_path" 2>/dev/null; then
                            echo "    ✓ Created and customized ${target_file}"
                            ((file_success++))
                        else
                            echo "    ⚠️  Failed to customize ${target_file}"
                            rm -f "$target_path"
                        fi
                    fi
                else
                    echo "    ⚠️  Failed to download ${template_file}"
                fi
            done
            
            if [ $file_success -gt 0 ]; then
                ((success_count++))
            else
                ((error_count++))
                rm -rf "$target_dir"
            fi
        else
            echo "  ⚠️  Failed to access ${template_dir}, skipping..."
            rm -rf "$target_dir"
            ((error_count++))
        fi
    done
    
    echo "🔄 Cleaning up temporary files..."
    echo "📊 Summary: $success_count directories processed successfully, $error_count failed"
    
    # Return success if at least some directories were processed
    [ $success_count -gt 0 ]
}

# Main script logic
main() {
    echo "🚀 Project AI initialization..."
    echo "Primary Project Type: $PRIMARY_PROJECT_TYPE"
    if [ ${#ADDITIONAL_PROJECT_TYPES[@]} -gt 0 ]; then
        echo "Additional Project Types: ${ADDITIONAL_PROJECT_TYPES[*]}"
    fi
    echo "Directory Name: $DIRECTORY"
    echo "Full Path: $FULL_PATH"
    
    # Validate Agent OS directories exist
    if ! validate_agent_os_directories; then
        return 1
    fi
    
    # Prompt user for IDE selection
    prompt_ide_selection
    
    # Create IDE-specific instruction file
    if ! create_instruction_file; then
        handle_error "Failed to create instruction file"
        return 1
    fi
    
    # Execute the copy and replace function for additional templates
    if copy_and_replace; then
        echo "✨ Project initialization complete!"
        if [ "$IDE_TYPE" = "vscode" ]; then
            echo "📁 Created VS Code instruction files:"
            echo "   - .github/instructions/main.instructions.md"
            echo "   - .github/copilot-instructions.md (for auto-detection)"
        else
            echo "📁 Created IDE-specific instruction file for $IDE_TYPE"
        fi
        echo "🎯 Referenced ${#ALL_PROJECT_TYPES[@]} project type(s): ${ALL_PROJECT_TYPES[*]}"
        echo "📂 Template files have been copied and customized."
        return 0
    else
        echo "⚠️  Project initialization completed with some errors."
        if [ "$IDE_TYPE" = "vscode" ]; then
            echo "📁 VS Code instruction files were created successfully."
        else
            echo "📁 IDE-specific instruction file was created successfully."
        fi
        echo "🎯 Referenced ${#ALL_PROJECT_TYPES[@]} project type(s): ${ALL_PROJECT_TYPES[*]}"
        echo "Please check the logs above for template copying details."
        return 1
    fi
}

# Execute main function
main "$@"
