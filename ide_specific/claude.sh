#!/bin/bash

# Claude IDE specific instruction file generator
# This file contains the logic for creating CLAUDE.md instruction files

# Function to backup existing file if it exists
backup_existing_file() {
    local file="$1"
    
    if [ -f "$file" ]; then
        local backup_file="${file}.old"
        echo "    📦 Backing up existing file: $(basename "$file") -> $(basename "$backup_file")"
        
        if mv "$file" "$backup_file"; then
            echo "    ✓ Successfully backed up to $(basename "$backup_file")"
        else
            echo "    ❌ Failed to backup $(basename "$file")"
            return 1
        fi
    fi
    
    return 0
}

# Function to update .gitignore for Claude specific files (if needed)
update_gitignore_for_claude() {
    local project_dir="$1"
    local gitignore_file="${project_dir}/.gitignore"
    
    # Currently Claude doesn't create symlinks that need to be ignored
    # This function is here for future extensibility
    echo "📝 Checking .gitignore for Claude-specific exclusions..."
    
    # For now, we don't need to add anything to .gitignore for Claude
    # The CLAUDE.md file should be committed as it's project-specific configuration
    echo "  ✓ No additional .gitignore entries needed for Claude"
    return 0
}

# Function to create CLAUDE.md symlink to main instructions
create_claude_symlink() {
    local project_dir="$1"
    local claude_file="${project_dir}/CLAUDE.md"
    local target_file="${project_dir}/.github/instructions/main.instructions.md"
    
    # Check if target file exists
    if [ ! -f "$target_file" ]; then
        echo "❌ Error: Target instructions file not found: $target_file"
        return 1
    fi
    
    # Backup existing CLAUDE.md if it exists and is not already a symlink
    if [ -f "$claude_file" ] && [ ! -L "$claude_file" ]; then
        backup_existing_file "$claude_file"
    elif [ -L "$claude_file" ]; then
        echo "    🔗 Removing existing symlink: CLAUDE.md"
        rm -f "$claude_file"
    fi
    
    # Create symlink
    if ln -sf ".github/instructions/main.instructions.md" "$claude_file"; then
        echo "    ✅ Created CLAUDE.md symlink -> .github/instructions/main.instructions.md"
        return 0
    else
        echo "    ❌ Failed to create CLAUDE.md symlink"
        return 1
    fi
}

# Function to set up Claude command integration
setup_claude_commands() {
    local project_dir="$1"
    local commands_dir="${project_dir}/reference-docs/commands"
    
    # Verify commands directory exists
    if [ ! -d "$commands_dir" ]; then
        echo "⚠️ Warning: Commands directory not found at: $commands_dir"
        return 1
    fi
    
    return 0
}

# Main setup function called by projectai.sh
setup_ide_environment() {
    local project_dir="$1"
    shift
    local project_types=("$@")
    
    echo "🔧 Setting up Claude Code environment..."
    
    # Create CLAUDE.md symlink to main instructions
    if ! create_claude_symlink "$project_dir"; then
        echo "❌ Error: Failed to create CLAUDE.md symlink"
        return 1
    fi
    
    # Configure command and prompt integration
    if ! setup_claude_commands "$project_dir"; then
        echo "⚠️ Warning: Command integration setup incomplete"
    fi
    
    # Update .gitignore for Claude-specific files
    update_gitignore_for_claude "$project_dir"
    
    echo "✅ Claude Code environment setup complete"
    return 0
}
