#!/bin/bash

# maintenance.sh
# Script for maintaining command and prompt organization in ~/.agent-os

# Function to add a new command
add_command() {
    local name="$1"
    local type="$2"  # common or project-specific
    local content="$3"
    local commands_dir="${HOME}/.agent-os/commands"
    
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
    
    # Update IDE configurations in current project
    update_ide_configs "command" "$name" "$type"
}

# Function to add a new prompt
add_prompt() {
    local name="$1"
    local type="$2"  # common or project-specific
    local content="$3"
    local prompts_dir="${HOME}/.agent-os/prompts"
    
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
    
    # Update IDE configurations in current project
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

# Function to validate ~/.agent-os directory structure
validate_structure() {
    local required_dirs=(
        "${HOME}/.agent-os/commands/common"
        "${HOME}/.agent-os/commands/project-specific"
        "${HOME}/.agent-os/prompts/common"
        "${HOME}/.agent-os/prompts/project-specific"
    )
    
    for dir in "${required_dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            echo "❌ Error: Missing required directory in ~/.agent-os: $dir"
            return 1
        fi
    done
    
    echo "✅ Directory structure in ~/.agent-os is valid"
    return 0
}

# Function to check for relative paths in IDE configs
check_relative_paths() {
    local config_files=(".vscode/settings.json" "CLAUDE.md" ".cursorrules")
    local has_absolute=0
    
    for file in "${config_files[@]}"; do
        if [ -f "$file" ]; then
            if grep -q "^/" "$file"; then
                echo "⚠️ Warning: Found absolute paths in $file"
                has_absolute=1
            fi
        fi
    done
    
    if [ $has_absolute -eq 0 ]; then
        echo "✅ All paths are relative"
        return 0
    fi
    return 1
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
