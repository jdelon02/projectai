#!/bin/bash

# Cursor IDE specific instruction file generator
# This file contains the logic for creating .cursorrules files

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

# Function to update .gitignore for Cursor specific files (if needed)
update_gitignore_for_cursor() {
    local project_dir="$1"
    local gitignore_file="${project_dir}/.gitignore"
    
    # Currently Cursor doesn't create symlinks that need to be ignored
    # This function is here for future extensibility
    echo "📝 Checking .gitignore for Cursor-specific exclusions..."
    
    # For now, we don't need to add anything to .gitignore for Cursor
    # The .cursorrules file should be committed as it's project-specific configuration
    echo "  ✓ No additional .gitignore entries needed for Cursor"
    return 0
}

# Function to create .cursorrules symlink to main instructions
create_cursor_symlink() {
    local project_dir="$1"
    local cursor_file="${project_dir}/.cursorrules"
    local target_file="${project_dir}/.github/instructions/main.instructions.md"
    
    # Check if target file exists
    if [ ! -f "$target_file" ]; then
        echo "❌ Error: Target instructions file not found: $target_file"
        return 1
    fi
    
    # Backup existing .cursorrules if it exists and is not already a symlink
    if [ -f "$cursor_file" ] && [ ! -L "$cursor_file" ]; then
        backup_existing_file "$cursor_file"
    elif [ -L "$cursor_file" ]; then
        echo "    🔗 Removing existing symlink: .cursorrules"
        rm -f "$cursor_file"
    fi
    
    # Create symlink
    if ln -sf ".github/instructions/main.instructions.md" "$cursor_file"; then
        echo "    ✅ Created .cursorrules symlink -> .github/instructions/main.instructions.md"
        return 0
    else
        echo "    ❌ Failed to create .cursorrules symlink"
        return 1
    fi
}

# Function to set up Cursor command and prompt integration
setup_cursor_integrations() {
    local project_dir="$1"
    
    # Verify required directories exist
    local required_dirs=(
        "${project_dir}/reference-docs/prompts"
        "${project_dir}/reference-docs/commands"
        "${project_dir}/reference-docs/standards"
        "${project_dir}/reference-docs/instructions"
        "${project_dir}/reference-docs/chatmodes"
    )
    
    for dir in "${required_dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            echo "⚠️ Warning: Required directory not found: $dir"
        fi
    done
    
    return 0
}

# Main setup function called by projectai.sh
setup_ide_environment() {
    local project_dir="$1"
    shift
    local project_types=("$@")
    
    echo "🔧 Setting up Cursor IDE environment..."
    
    # Create .cursorrules symlink to main instructions
    if ! create_cursor_symlink "$project_dir"; then
        echo "❌ Error: Failed to create .cursorrules symlink"
        return 1
    fi
    
    # Set up command and prompt integration
    if ! setup_cursor_integrations "$project_dir"; then
        echo "⚠️ Warning: Integration setup incomplete"
    fi
    
    # Update .gitignore for Cursor-specific files
    update_gitignore_for_cursor "$project_dir"
    
    echo "✅ Cursor IDE environment setup complete"
    return 0
}
