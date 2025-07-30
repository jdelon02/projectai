#!/bin/bash

# projectai.sh
# Description: Main script for project AI operations that extends agent-os functionality.
# This script initializes a project by copying templates from a GitHub repository,
# customizing them based on user input, and setting up the project structure.
# Created: July 24, 2025
# Usage: projectai <project_type>

# Exit on error
set -e

# Array to track exported variables for cleanup
EXPORTED_VARS=()

# Array to track temporary files for cleanup
TEMP_FILES=()

# Function to cleanup temporary IDE script
cleanup_temp_script() {
    local temp_script="$1"
    if [ -f "$temp_script" ]; then
        echo "  🗑️  Cleaning up temporary IDE script: $temp_script"
        rm -f "$temp_script"
    fi
}

# Function to cleanup temporary template directory
cleanup_temp_dir() {
    local temp_dir="$1"
    if [ -d "$temp_dir" ]; then
        echo "🗑️  Cleaning up temporary template directory: $temp_dir"
        rm -rf "$temp_dir"
    fi
}

# Function to cleanup environment and temporary files
cleanup_environment() {
    local exit_code=$?
    
    echo "🧹 Cleaning up environment..."
    
    # Clean up tracked temporary files
    if [ ${#TEMP_FILES[@]} -gt 0 ]; then
        echo "  🗑️  Cleaning up tracked temporary files..."
        for temp_file in "${TEMP_FILES[@]}"; do
            if [ -e "$temp_file" ]; then
                echo "    ✓ Removing $temp_file"
                rm -rf "$temp_file" 2>/dev/null || true
            fi
        done
        echo "  ✓ Tracked temporary files cleaned up"
    fi
    
    # Unset exported variables
    if [ ${#EXPORTED_VARS[@]} -gt 0 ]; then
        echo "  🔄 Cleaning up exported environment variables..."
        for var in "${EXPORTED_VARS[@]}"; do
            if [ -n "${!var+x}" ]; then
                echo "    ✓ Unsetting $var"
                unset "$var"
            fi
        done
        echo "  ✓ Environment variables cleaned up"
    fi
    
    # Clean up any remaining temporary files (belt and suspenders approach)
    local temp_files=(/tmp/tmp.* /tmp/projectai-*)
    for temp_file in "${temp_files[@]}"; do
        if [[ -e "$temp_file" && "$temp_file" == *"projectai"* ]]; then
            rm -rf "$temp_file" 2>/dev/null || true
        fi
    done
    
    echo "  ✓ Cleanup completed"
    return $exit_code
}

# Set up cleanup trap to run on script exit (success, error, or interruption)
trap cleanup_environment EXIT INT TERM

# Function to safely export variables with tracking
safe_export() {
    local var_name="$1"
    local var_value="$2"
    
    # Export the variable
    export "$var_name"="$var_value"
    
    # Add to tracking array for cleanup
    EXPORTED_VARS+=("$var_name")
}

# Function to handle errors gracefully
handle_error() {
    local error_message="$1"
    echo "❌ Error: $error_message"
    return 1
}

# Check if we have the required arguments
if [ "$#" -lt 1 ]; then
    echo "Error: Missing project type argument(s)"
    echo "Usage: projectai <primary_project_type> [additional_project_types...]"
    echo "       projectai none  # Skip Agent OS symlinks, only create IDE configs and templates"
    echo "Example: projectai drupal php mysql css javascript lando"
    echo "Example: projectai none  # Create project structure without Agent OS dependencies"
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
    echo "  projectai drupal,php,mysql,css,javascript,lando"
    echo "  projectai react typescript tailwind"
    echo "  projectai python fastapi postgresql"
    echo "  projectai none  # Skip Agent OS setup, only create IDE configs and templates"
    echo ""
    echo "Special Arguments:"
    echo "  none             Skip Agent OS symlinks and validation"
    echo "                   Creates IDE configuration and templates only"
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

# Function to update .gitignore to exclude Agent OS symlinks
update_gitignore_for_agent_os() {
    local project_dir="$1"
    local gitignore_file="${project_dir}/.gitignore"
    
    echo "📝 Updating .gitignore to exclude Agent OS symlinks..."
    
    # Define patterns to add to .gitignore
    local ignore_patterns=(
        "# Agent OS symlinked directories (auto-generated by projectai.sh)"
        "reference-docs/standards"
        "reference-docs/instructions" 
        "reference-docs/commands"
        "reference-docs/chatmodes"
        "reference-docs/prompts"
    )
    
    # Add project-specific patterns
    for type in "${ALL_PROJECT_TYPES[@]}"; do
        ignore_patterns+=("reference-docs/${type}")
    done
    
    # Check if .gitignore exists, create if it doesn't
    if [ ! -f "$gitignore_file" ]; then
        echo "  📝 Creating new .gitignore file"
        touch "$gitignore_file"
    fi
    
    # Check if Agent OS section already exists
    if grep -q "# Agent OS symlinked directories" "$gitignore_file" 2>/dev/null; then
        echo "  ✓ Agent OS section already exists in .gitignore"
        return 0
    fi
    
    # Add Agent OS section to .gitignore
    echo "  📝 Adding Agent OS exclusions to .gitignore"
    echo "" >> "$gitignore_file"
    for pattern in "${ignore_patterns[@]}"; do
        echo "$pattern" >> "$gitignore_file"
    done
    
    echo "  ✓ Updated .gitignore with ${#ignore_patterns[@]} patterns"
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
    # Check for special "none" argument
    if [[ "${1,,}" == "none" ]]; then
        echo "🚫 'none' mode selected - skipping Agent OS symlinks and validation"
        SKIP_AGENT_OS=true
        PRIMARY_PROJECT_TYPE="generic"
        ADDITIONAL_PROJECT_TYPES=()
        ALL_PROJECT_TYPES=("generic")
    else
        # Handle both comma-separated and space-separated arguments
        ALL_TYPES=()
        
        # Check if first argument contains commas (comma-separated format)
        if [[ "$1" == *","* ]]; then
            # Parse comma-separated input
            IFS=',' read -r -a ALL_TYPES <<< "$1"
        else
            # Parse space-separated arguments (all command line arguments)
            ALL_TYPES=("$@")
        fi
        
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
        
        SKIP_AGENT_OS=false
    fi
fi

# Set derived variables only if they don't exist
if [ -z "${ALL_PROJECT_TYPES+x}" ]; then
    if [ "$SKIP_AGENT_OS" = true ]; then
        ALL_PROJECT_TYPES=("generic")
    else
        ALL_PROJECT_TYPES=("$PRIMARY_PROJECT_TYPE" "${ADDITIONAL_PROJECT_TYPES[@]}")
    fi
fi

if [ -z "${FULL_PATH+x}" ]; then
    FULL_PATH="$(pwd)"
fi

if [ -z "${DIRECTORY+x}" ]; then
    DIRECTORY=$(basename "$FULL_PATH")
fi

# Base URL for raw GitHub content
BASE_URL="https://raw.githubusercontent.com/jdelon02/projectai/main"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

# Function to create IDE-specific instruction file
create_instruction_file() {
    echo "📝 Setting up IDE-specific configuration..."
    
    # Set up GitHub URL for IDE script
    local ide_script_url="${BASE_URL}/ide_specific/${IDE_TYPE}.sh"
    
    # Export variables needed by IDE scripts with tracking for cleanup
    echo "  📤 Exporting variables for IDE script..."
    safe_export "PRIMARY_PROJECT_TYPE" "$PRIMARY_PROJECT_TYPE"
    safe_export "ADDITIONAL_PROJECT_TYPES_STR" "${ADDITIONAL_PROJECT_TYPES[*]}"
    safe_export "ALL_PROJECT_TYPES_STR" "${ALL_PROJECT_TYPES[*]}"
    safe_export "FULL_PATH" "$FULL_PATH"
    safe_export "DIRECTORY" "$DIRECTORY"
    safe_export "BASE_URL" "$BASE_URL"
    safe_export "SCRIPT_DIR" "$SCRIPT_DIR"
    
    echo "  🔧 Running IDE-specific setup for ${IDE_TYPE} in ${FULL_PATH}..."
    
    # Download the script to a temporary file with projectai prefix
    local temp_script
    temp_script=$(mktemp -t projectai-ide-script-XXXXXX.sh) || {
        handle_error "Failed to create temporary script file"
        return 1
    }

    # Add to tracked temporary files for cleanup
    TEMP_FILES+=("$temp_script")

    # Make it executable
    chmod +x "$temp_script"

    if ! curl -sSL "$ide_script_url" -o "$temp_script"; then
        handle_error "Failed to download IDE script from $ide_script_url"
        return 1
    fi
    
    # Change to the project directory and execute the IDE script
    echo "  📜 Executing IDE script from: $ide_script_url"
    if ! (cd "${FULL_PATH}" && bash -x "$temp_script"); then
        handle_error "IDE setup script failed"
        return 1
    fi
    
    # Clean up the temp script immediately after use
    cleanup_temp_script "$temp_script"
    
    echo "  ✓ IDE script executed successfully"
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
    
    # Create temporary directory for downloads with projectai prefix for cleanup
    local temp_dir
    temp_dir=$(mktemp -d -t projectai-templates-XXXXXX) || {
        handle_error "Failed to create temporary directory"
        return 1
    }
    
    # Add to tracked temporary files for cleanup
    TEMP_FILES+=("$temp_dir")
    
    # Use GitHub API to list repository contents
    echo "📂 Fetching template directory structure..."
    local api_url="https://api.github.com/repos/jdelon02/projectai/contents/project_templates"
    
    # Fetch directory listing from GitHub API
    local file_list
    file_list=$(curl -sSL -H "Accept: application/vnd.github.v3+json" "$api_url") || {
        handle_error "Failed to fetch directory listing from GitHub API"
        return 1
    }
    
    # Parse JSON to get directory names - most robust approach
    local template_dirs=()
    # Process the JSON line by line to find directories
    local current_name=""
    while IFS= read -r line; do
        # Check if this line contains a name
        if [[ $line =~ \"name\":\ *\"([^\"]+)\" ]]; then
            current_name="${BASH_REMATCH[1]}"
        # Check if this line indicates it's a directory
        elif [[ $line =~ \"type\":\ *\"dir\" ]] && [ -n "$current_name" ]; then
            template_dirs+=("$current_name")
            current_name=""
        fi
    done < <(echo "$file_list")
    
    echo "🔍 Debug: Found directories: ${template_dirs[*]}"
    
    if [ ${#template_dirs[@]} -eq 0 ]; then
        handle_error "No template directories found in project_templates/"
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
        
        # Get file list for this directory from GitHub API
        local dir_contents
        dir_contents=$(curl -sSL -H "Accept: application/vnd.github.v3+json" "$api_url/${template_dir}") || {
            echo "  ⚠️  Failed to list files in ${template_dir}, skipping..."
            ((error_count++))
            continue
        }
        
        # Parse JSON to get file names - most robust approach
        local files=()
        local current_name=""
        while IFS= read -r line; do
            # Check if this line contains a name
            if [[ $line =~ \"name\":\ *\"([^\"]+)\" ]]; then
                current_name="${BASH_REMATCH[1]}"
            # Check if this line indicates it's a file
            elif [[ $line =~ \"type\":\ *\"file\" ]] && [ -n "$current_name" ]; then
                # Only include markdown and config files
                if [[ $current_name =~ \.(md|json|yaml|yml)$ ]]; then
                    files+=("$current_name")
                fi
                current_name=""
            fi
        done < <(echo "$dir_contents")
        
        echo "  🔍 Debug: Found files in $template_dir: ${files[*]}"
            
        local file_success=0
        for template_file in "${files[@]}"; do
            local target_file="$template_file"
            local target_path="${target_dir}/${target_file}"
            local raw_url="${BASE_URL}/project_templates/${template_dir}/${template_file}"
            
            echo "  ⬇️  Downloading ${template_file}..."
            if curl -sSL --fail -o "$target_path" "$raw_url"; then
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
    done
    
    echo "🔄 Cleaning up temporary files..."
    cleanup_temp_dir "$temp_dir"
    echo "📊 Summary: $success_count directories processed successfully, $error_count failed"
    
    # Return success if at least some directories were processed
    [ $success_count -gt 0 ]
}

# Main script logic
main() {
    echo "🚀 Project AI initialization..."
    
    if [ "$SKIP_AGENT_OS" = true ]; then
        echo "🚫 Running in 'none' mode - skipping Agent OS setup"
        echo "Directory Name: $DIRECTORY"
        echo "Full Path: $FULL_PATH"
    else
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
        
        # Create Agent OS symlinks BEFORE IDE setup
        echo "🔗 Setting up Agent OS reference documentation..."
        create_global_symlinks "$FULL_PATH"
        create_project_type_symlinks "$FULL_PATH" "${ALL_PROJECT_TYPES[@]}"
        
        # Update .gitignore to exclude symlinked directories
        update_gitignore_for_agent_os "$FULL_PATH"
    fi
    
    # Prompt user for IDE selection
    prompt_ide_selection
    
    # Create IDE-specific instruction file (now that reference-docs exist)
    if ! create_instruction_file; then
        handle_error "Failed to create instruction file"
        return 1
    fi
    
    # Execute the copy and replace function for additional templates
    if copy_and_replace; then
        echo "✨ Project initialization complete!"
        if [ "$IDE_TYPE" = "vscode" ]; then
            echo "📁 Created VS Code configuration:"
            echo "   - .github/instructions/main.instructions.md"
            echo "   - .github/copilot-instructions.md (for auto-detection)"
            echo "   - .vscode/${DIRECTORY}.code-workspace (comprehensive workspace settings)"
        else
            echo "📁 Created IDE-specific instruction file for $IDE_TYPE"
        fi
        
        if [ "$SKIP_AGENT_OS" = true ]; then
            echo "🚫 Skipped Agent OS symlinks as requested ('none' mode)"
            echo "📁 Created IDE configuration and templates only"
        else
            echo "🎯 Referenced ${#ALL_PROJECT_TYPES[@]} project type(s): ${ALL_PROJECT_TYPES[*]}"
            echo "🚫 Updated .gitignore to exclude Agent OS symlinks from version control."
        fi
        echo "📂 Template files have been copied and customized."
        echo "🎉 Project setup completed successfully!"
        return 0
    else
        echo "⚠️  Project initialization completed with some errors."
        if [ "$IDE_TYPE" = "vscode" ]; then
            echo "📁 VS Code configuration was created successfully."
        else
            echo "📁 IDE-specific instruction file was created successfully."
        fi
        
        if [ "$SKIP_AGENT_OS" = true ]; then
            echo "🚫 Skipped Agent OS symlinks as requested ('none' mode)"
        else
            echo "🎯 Referenced ${#ALL_PROJECT_TYPES[@]} project type(s): ${ALL_PROJECT_TYPES[*]}"
            echo "🚫 Updated .gitignore to exclude Agent OS symlinks from version control."
        fi
        echo "📂 Please check the logs above for template copying details."
        echo "⚠️  Project setup completed with some template errors."
        return 1
    fi
}

# Execute main function
main "$@"
