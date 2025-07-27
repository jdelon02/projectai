#!/bin/bash

# projectai.sh
# Description: Main script for project AI operations that extends agent-os functionality.
# This script initializes a project by copying templates from a GitHub repository,
# customizing them based on user input, and setting up the project structure.
# Created: July 24, 2025
# Usage: projectai <project_type>

# Exit on error
set -e

# Check if we have the required arguments
if [ "$#" -lt 1 ]; then
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

# Set variables
PRIMARY_PROJECT_TYPE="$1"
shift # Remove first argument
ADDITIONAL_PROJECT_TYPES=("$@") # Remaining arguments as array
ALL_PROJECT_TYPES=("$PRIMARY_PROJECT_TYPE" "${ADDITIONAL_PROJECT_TYPES[@]}")
FULL_PATH="$(pwd)"
DIRECTORY=$(basename "$FULL_PATH")

# Base URL for raw GitHub content
BASE_URL="https://raw.githubusercontent.com/jdelon02/agent-os/main"

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

# Function to handle errors gracefully
handle_error() {
    local error_message="$1"
    echo "❌ Error: $error_message"
    return 1
}

# Function to create IDE-specific instruction file
create_instruction_file() {
    echo "📝 Creating IDE-specific instruction file..."
    
    # Generate project types list for display
    local project_types_display
    if [ ${#ALL_PROJECT_TYPES[@]} -eq 1 ]; then
        project_types_display="$PRIMARY_PROJECT_TYPE"
    else
        project_types_display="$PRIMARY_PROJECT_TYPE (+ ${ADDITIONAL_PROJECT_TYPES[*]})"
    fi
    
    case $IDE_TYPE in
        "claude")
            local instruction_file="$FULL_PATH/CLAUDE.md"
            cat > "$instruction_file" << EOF
# CLAUDE.md

> Agent OS Project Instructions
> Primary Project Type: $PRIMARY_PROJECT_TYPE
> Additional Types: ${ADDITIONAL_PROJECT_TYPES[*]}
> Directory: $DIRECTORY
> Generated: $(date +"%Y-%m-%d")

## Purpose

This file directs Claude Code to use your Agent OS standards for this multi-type project ($project_types_display). These instructions reference your global Agent OS installation and provide project-specific context.

## Primary Project Standards ($PRIMARY_PROJECT_TYPE)

### Development Standards
- **Tech Stack Defaults:** @~/.agent-os/$PRIMARY_PROJECT_TYPE/tech-stack.md
- **Code Style Preferences:** @~/.agent-os/$PRIMARY_PROJECT_TYPE/code-style.md
- **Best Practices Philosophy:** @~/.agent-os/$PRIMARY_PROJECT_TYPE/best-practices.md
- **Main Instructions:** @~/.agent-os/$PRIMARY_PROJECT_TYPE/main.instructions.md

## Additional Technology Standards

EOF
            
            # Add references for additional project types
            for project_type in "${ADDITIONAL_PROJECT_TYPES[@]}"; do
                cat >> "$instruction_file" << EOF
### $project_type Standards
- **Tech Stack:** @~/.agent-os/$project_type/tech-stack.md
- **Code Style:** @~/.agent-os/$project_type/code-style.md
- **Best Practices:** @~/.agent-os/$project_type/best-practices.md
- **Instructions:** @~/.agent-os/$project_type/main.instructions.md

EOF
            done
            
            cat >> "$instruction_file" << EOF
## Agent OS Instructions
- **Initialize Products:** @~/.agent-os/instructions/plan-product.md
- **Plan Features:** @~/.agent-os/instructions/create-spec.md
- **Execute Tasks:** @~/.agent-os/instructions/execute-tasks.md
- **Analyze Existing Code:** @~/.agent-os/instructions/analyze-product.md

## Project Context

- **Primary Type:** $PRIMARY_PROJECT_TYPE
- **Additional Types:** ${ADDITIONAL_PROJECT_TYPES[*]}
- **Directory Name:** $DIRECTORY
- **Full Path:** $FULL_PATH

## Using Agent OS Commands

You can invoke Agent OS commands directly:
- \`/plan-product\` - Start planning this product
- \`/create-spec\` - Plan a new feature for this project
- \`/execute-task\` - Build and ship code for this project
- \`/analyze-product\` - Analyze this existing codebase

## Important Notes

- Primary standards from \`~/.agent-os/$PRIMARY_PROJECT_TYPE/\` take precedence
- Additional technology standards provide supplementary guidance
- Project-specific files in this directory override global defaults
- Update Agent OS standards as you discover new patterns

---

*Using Agent OS for structured AI-assisted development. Learn more at [buildermethods.com/agent-os](https://buildermethods.com/agent-os)*
EOF
            echo "    ✓ Created CLAUDE.md instruction file"
            ;;
            
        "vscode")
            # Create .github/instructions directory
            local instructions_dir="$FULL_PATH/.github/instructions"
            mkdir -p "$instructions_dir"
            local instruction_file="$instructions_dir/main.instructions.md"
            cat > "$instruction_file" << EOF
# GitHub Copilot Instructions

> Agent OS Project Instructions
> Primary Project Type: $PRIMARY_PROJECT_TYPE
> Additional Types: ${ADDITIONAL_PROJECT_TYPES[*]}
> Directory: $DIRECTORY
> Generated: $(date +"%Y-%m-%d")

## Project Context

This is a **$PRIMARY_PROJECT_TYPE** project with additional technologies (${ADDITIONAL_PROJECT_TYPES[*]}) using Agent OS structured development workflows.

## Primary Standards Reference ($PRIMARY_PROJECT_TYPE)
- Main Instructions: \`~/.agent-os/$PRIMARY_PROJECT_TYPE/main.instructions.md\`
- Tech Stack Standards: \`~/.agent-os/$PRIMARY_PROJECT_TYPE/tech-stack.md\`
- Code Style Guide: \`~/.agent-os/$PRIMARY_PROJECT_TYPE/code-style.md\`
- Best Practices: \`~/.agent-os/$PRIMARY_PROJECT_TYPE/best-practices.md\`

## Additional Technology Standards

EOF
            
            # Add references for additional project types
            for project_type in "${ADDITIONAL_PROJECT_TYPES[@]}"; do
                cat >> "$instruction_file" << EOF
### $project_type
- Instructions: \`~/.agent-os/$project_type/main.instructions.md\`
- Tech Stack: \`~/.agent-os/$project_type/tech-stack.md\`
- Code Style: \`~/.agent-os/$project_type/code-style.md\`
- Best Practices: \`~/.agent-os/$project_type/best-practices.md\`

EOF
            done
            
            cat >> "$instruction_file" << EOF
## Development Guidelines

Please follow the Agent OS methodology:

1. **Plan First**: Always understand the full scope before coding
2. **Spec-Driven**: Create detailed specifications for complex features
3. **Standards Compliance**: Follow the $PRIMARY_PROJECT_TYPE standards primarily, with guidance from additional technologies
4. **Modular Design**: Maintain separation of concerns and clean architecture

## Project Information
- **Primary Type**: $PRIMARY_PROJECT_TYPE
- **Additional Types**: ${ADDITIONAL_PROJECT_TYPES[*]}
- **Name**: $DIRECTORY
- **Path**: $FULL_PATH

## Agent OS Workflows

When working on this project:
- Reference \`~/.agent-os/instructions/plan-product.md\` for product planning
- Use \`~/.agent-os/instructions/create-spec.md\` for feature specification
- Follow \`~/.agent-os/instructions/execute-tasks.md\` for implementation
- Apply \`~/.agent-os/instructions/analyze-product.md\` for code analysis

---

*Using Agent OS for structured AI-assisted development with GitHub Copilot*
EOF
            echo "    ✓ Created .github/instructions/main.instructions.md file"
            
            # Copy and customize copilot-instructions.md template
            local copilot_file="$FULL_PATH/.github/copilot-instructions.md"
            local copilot_template="${BASE_URL}/project_templates/.github/copilot-instructions.md"
            
            if curl -s --fail -o "$copilot_file" "$copilot_template" 2>/dev/null; then
                # Create replacement strings for multiple project types
                local additional_types_str="${ADDITIONAL_PROJECT_TYPES[*]}"
                local all_types_str="${ALL_PROJECT_TYPES[*]}"
                
                if sed -i '' \
                    -e "s/<PROJECTTYPE>/$PRIMARY_PROJECT_TYPE/g" \
                    -e "s/<DIRECTORY_NAME>/$DIRECTORY/g" \
                    -e "s/<ADDITIONAL_TYPES>/$additional_types_str/g" \
                    -e "s/<ALL_TYPES>/$all_types_str/g" \
                    -e "s|<FULL_PATH>|$FULL_PATH|g" \
                    "$copilot_file" 2>/dev/null; then
                    echo "    ✓ Created .github/copilot-instructions.md for auto-detection"
                else
                    echo "    ⚠️  Created copilot-instructions.md but failed to customize placeholders"
                fi
            else
                echo "    ⚠️  Failed to download copilot-instructions.md template, creating basic version"
                # Fallback to a simple version if template download fails
                cat > "$copilot_file" << EOF
# GitHub Copilot Instructions

For complete instructions, see: [Main Instructions](instructions/main.instructions.md)

This is a **$PRIMARY_PROJECT_TYPE** project using Agent OS structured development workflows.
EOF
            fi
            ;;
            
        "cursor")
            local instruction_file="$FULL_PATH/.cursorrules"
            cat > "$instruction_file" << EOF
# Cursor IDE Rules - Agent OS Project

# Primary Project Type: $PRIMARY_PROJECT_TYPE
# Additional Types: ${ADDITIONAL_PROJECT_TYPES[*]}
# Directory: $DIRECTORY
# Generated: $(date +"%Y-%m-%d")

# Agent OS Standards
You are working on a $PRIMARY_PROJECT_TYPE project with additional technologies (${ADDITIONAL_PROJECT_TYPES[*]}) using Agent OS structured development methodology.

## Primary Reference Files ($PRIMARY_PROJECT_TYPE)
- Main Instructions: ~/.agent-os/$PRIMARY_PROJECT_TYPE/main.instructions.md
- Tech Stack Standards: ~/.agent-os/$PRIMARY_PROJECT_TYPE/tech-stack.md
- Code Style Guide: ~/.agent-os/$PRIMARY_PROJECT_TYPE/code-style.md
- Best Practices: ~/.agent-os/$PRIMARY_PROJECT_TYPE/best-practices.md

EOF
            
            # Add references for additional project types
            for project_type in "${ADDITIONAL_PROJECT_TYPES[@]}"; do
                cat >> "$instruction_file" << EOF
## Additional Standards ($project_type)
- Instructions: ~/.agent-os/$project_type/main.instructions.md
- Tech Stack: ~/.agent-os/$project_type/tech-stack.md
- Code Style: ~/.agent-os/$project_type/code-style.md
- Best Practices: ~/.agent-os/$project_type/best-practices.md

EOF
            done
            
            cat >> "$instruction_file" << EOF
## Development Approach
1. Always reference the Agent OS standards, prioritizing $PRIMARY_PROJECT_TYPE as primary
2. Apply additional technology standards as supplementary guidance
3. Follow spec-driven development - plan before implementing
4. Maintain clean, modular architecture
5. Document architectural decisions
6. Follow the established conventions for all referenced technologies

## Project Context
- Primary Type: $PRIMARY_PROJECT_TYPE
- Additional Types: ${ADDITIONAL_PROJECT_TYPES[*]}
- Name: $DIRECTORY
- Path: $FULL_PATH

## Agent OS Workflow Integration
- Plan products using ~/.agent-os/instructions/plan-product.md
- Create specifications with ~/.agent-os/instructions/create-spec.md
- Execute tasks following ~/.agent-os/instructions/execute-tasks.md
- Analyze code using ~/.agent-os/instructions/analyze-product.md

Always prioritize code quality, maintainability, and adherence to the established Agent OS standards for this multi-technology project.
EOF
            echo "    ✓ Created .cursorrules file with ${#ALL_PROJECT_TYPES[@]} project type(s)"
            ;;
    esac
    
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
