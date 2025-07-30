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

# Function to generate .cursorrules with proper configurations
generate_cursor_rules() {
    local project_dir="$1"
    local cursor_file="${project_dir}/.cursorrules"
    
    # Backup existing file if it exists
    backup_existing_file "$cursor_file"
    
    cat > "$cursor_file" << 'EOF'
{
    "prompts": {
        "source": "./reference-docs/prompts",
        "common": {
            "path": "./reference-docs/prompts/common",
            "description": "Common development workflow prompts and templates"
        },
        "projectSpecific": {
            "path": "./reference-docs/prompts/project-specific",
            "description": "Project type-specific prompts and templates"
        }
    },
    "commands": {
        "source": "./reference-docs/commands",
        "common": {
            "path": "./reference-docs/commands/common",
            "description": "Common development workflow commands"
        },
        "projectSpecific": {
            "path": "./reference-docs/commands/project-specific",
            "description": "Project type-specific commands and tools"
        }
    },
    "standards": "./reference-docs/standards",
    "instructions": "./reference-docs/instructions",
    "chatmodes": "./reference-docs/chatmodes",
    "maintenance": {
        "sourceTruth": "reference-docs",
        "relativePathsOnly": true,
        "updateTriggers": ["newCommand", "newPrompt"]
    }
}
EOF
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
    
    # Generate .cursorrules with proper configurations
    if ! generate_cursor_rules "$project_dir"; then
        echo "❌ Error: Failed to generate .cursorrules"
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
    
    # Report success
    echo "✓ Cursor IDE setup completed successfully"
    return 0
}

create_cursor_instruction_file() {
    local project_types_display="$1"
    local instruction_file="$FULL_PATH/.cursorrules"
    local template_url="${BASE_URL}/project_templates/cursor-ide/.cursorrules"

    # Backup existing file if it exists
    backup_existing_file "$instruction_file"

    if curl -s --fail -o "$instruction_file" "$template_url" 2>/dev/null; then
        if [ -f "$instruction_file" ]; then
local additional_sections=""
            for project_type in "${ADDITIONAL_PROJECT_TYPES[@]}"; do
                additional_sections+="## Additional Standards ($project_type)"$'
'
                additional_sections+="- Instructions: ~/.agent-os/$project_type/main.instructions.md"$'
'
                additional_sections+="- Tech Stack: ~/.agent-os/$project_type/tech-stack.md"$'
'
                additional_sections+="- Code Style: ~/.agent-os/$project_type/code-style.md"$'
'
                additional_sections+="- Best Practices: ~/.agent-os/$project_type/best-practices.md"$'
'$'
'
            done

            # Create replacement strings
            local additional_types_str="${ADDITIONAL_PROJECT_TYPES[*]}"
            local all_types_str="${ALL_PROJECT_TYPES[*]}"

            if sed -i '' 
                -e "s/<PROJECTTYPE>/$PRIMARY_PROJECT_TYPE/g" 
                -e "s/<DIRECTORY_NAME>/$DIRECTORY/g" 
                -e "s/<ADDITIONAL_TYPES>/$additional_types_str/g" 
                -e "s/<ALL_TYPES>/$all_types_str/g" 
                -e "s/<ADDITIONAL_SECTIONS>/$additional_sections/g" 
                "$instruction_file" 2>/dev/null; then
                echo "    ✓ Created and customized .cursorrules file with ${#ALL_PROJECT_TYPES[@]} project type(s)"
            else
                echo "    ⚠️  Created .cursorrules but failed to customize placeholders"
            fi
        fi
    else
        echo "    ⚠️  Failed to download .cursorrules template, creating basic version"
        # Backup existing file if it exists
        backup_existing_file "$instruction_file"
        
        # Fallback to a simple version if template download fails
        cat > "$instruction_file" << EOF

EOF
    
    # Add references for additional project types
    for project_type in "${ADDITIONAL_PROJECT_TYPES[@]}"; do
        cat >> "$instruction_file" << EOF
# Cursor IDE Rules - Agent OS Project

You are working on a $PRIMARY_PROJECT_TYPE project using Agent OS structured development methodology.

Main Instructions: ~/.agent-os/$PRIMARY_PROJECT_TYPE/main.instructions.md"
EOF
    fi
    
    return 0
    
    echo "    ✓ Created .cursorrules file with ${#ALL_PROJECT_TYPES[@]} project type(s)"
    return 0
}
