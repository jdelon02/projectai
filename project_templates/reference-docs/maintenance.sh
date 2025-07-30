#!/bin/bash

# maintenance.sh
# Script for maintaining command and prompt organization

# Function to add a new command
add_command() {
    local name="$1"
    local type="$2"  # common or project-specific
    local content="$3"
    local commands_dir="reference-docs/commands"
    
    case "$type" in
        common)
            target_dir="${commands_dir}/common"
            ;;
        project-specific)
            target_dir="${commands_dir}/project-specific"
            ;;
        *)
            echo "❌ Error: Invalid command type. Use 'common' or 'project-specific'"
            return 1
            ;;
    esac
    
    # Create command file
    echo "$content" > "${target_dir}/${name}.sh"
    
    # Update IDE configurations
    update_ide_configs "command" "$name" "$type"
}

# Function to add a new prompt
add_prompt() {
    local name="$1"
    local type="$2"  # common or project-specific
    local content="$3"
    local prompts_dir="reference-docs/prompts"
    
    case "$type" in
        common)
            target_dir="${prompts_dir}/common"
            ;;
        project-specific)
            target_dir="${prompts_dir}/project-specific"
            ;;
        *)
            echo "❌ Error: Invalid prompt type. Use 'common' or 'project-specific'"
            return 1
            ;;
    esac
    
    # Create prompt file
    echo "$content" > "${target_dir}/${name}.md"
    
    # Update IDE configurations
    update_ide_configs "prompt" "$name" "$type"
}

# Function to update IDE configurations
update_ide_configs() {
    local item_type="$1"  # command or prompt
    local name="$2"
    local type="$3"  # common or project-specific
    
    # Update VS Code settings
    if [ -f ".vscode/settings.json" ]; then
        echo "Updating VS Code settings..."
        # TODO: Add JSON update logic
    fi
    
    # Update Claude.md
    if [ -f "CLAUDE.md" ]; then
        echo "Updating Claude.md..."
        # TODO: Add markdown update logic
    fi
    
    # Update .cursorrules
    if [ -f ".cursorrules" ]; then
        echo "Updating .cursorrules..."
        # TODO: Add JSON update logic
    fi
}

# Function to validate directory structure
validate_structure() {
    local required_dirs=(
        "reference-docs/commands/common"
        "reference-docs/commands/project-specific"
        "reference-docs/prompts/common"
        "reference-docs/prompts/project-specific"
    )
    
    for dir in "${required_dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            echo "❌ Error: Missing required directory: $dir"
            return 1
        fi
    done
    
    echo "✅ Directory structure is valid"
    return 0
}

# Function to check for relative paths
check_relative_paths() {
    local absolute_paths=$(find reference-docs -type f -exec grep -l "^/" {} \;)
    
    if [ -n "$absolute_paths" ]; then
        echo "⚠️ Warning: Found absolute paths in:"
        echo "$absolute_paths"
        return 1
    fi
    
    echo "✅ All paths are relative"
    return 0
}

# Main function
main() {
    case "$1" in
        add-command)
            add_command "$2" "$3" "$4"
            ;;
        add-prompt)
            add_prompt "$2" "$3" "$4"
            ;;
        validate)
            validate_structure
            check_relative_paths
            ;;
        *)
            echo "Usage:"
            echo "  $0 add-command <name> <type> <content>"
            echo "  $0 add-prompt <name> <type> <content>"
            echo "  $0 validate"
            exit 1
            ;;
    esac
}

main "$@"
