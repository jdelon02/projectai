#!/bin/bash

# VS Code IDE specific instruction file generator
# This file contains the logic for creating .github/instructions/main.instructions.md files
# and handling VS Code workspace files

# Function to set up VS Code IDE environment
ide_setup() {
    echo "🔧 Setting up VS Code environment..."
    
    # Create .github/instructions directory
    mkdir -p "${FULL_PATH}/.github/instructions"
    
    # Create main instructions file
    local instructions_file="${FULL_PATH}/.github/instructions/main.instructions.md"
    local copilot_file="${FULL_PATH}/.github/copilot-instructions.md"
    
    # Create both files with appropriate content
    create_vscode_instructions "$instructions_file"
    create_copilot_autodetect "$copilot_file"
    
    # Configure VS Code workspace settings
    configure_vscode_workspace "${FULL_PATH}"
    
    return 0
}

# Function to create VS Code instructions file
create_vscode_instructions() {
    local file="$1"
    local template_url="${BASE_URL}/project_templates/.github/instructions/main.instructions.md"
    
    # Download template and apply substitutions
    if curl -sSL --fail "$template_url" -o "$file"; then
        # Apply template substitutions
        local additional_types_str="${ADDITIONAL_PROJECT_TYPES[*]}"
        local all_types_str="${ALL_PROJECT_TYPES[*]}"
        
        sed -i '' \
            -e "s/<PROJECTTYPE>/$PRIMARY_PROJECT_TYPE/g" \
            -e "s/<DIRECTORY_NAME>/$DIRECTORY/g" \
            -e "s/<ADDITIONAL_TYPES>/$additional_types_str/g" \
            -e "s/<ALL_TYPES>/$all_types_str/g" \
            "$file" 2>/dev/null
        
        echo "    ✓ Created ${file} from template"
    else
        echo "    ❌ Failed to download template from ${template_url}"
        return 1
    fi
}

# Function to create Copilot auto-detect file
create_copilot_autodetect() {
    local file="$1"
    local template_url="${BASE_URL}/project_templates/.github/copilot-instructions.md"
    
    # Download template and apply substitutions
    if curl -sSL --fail "$template_url" -o "$file"; then
        # Apply template substitutions
        local additional_types_str="${ADDITIONAL_PROJECT_TYPES[*]}"
        local all_types_str="${ALL_PROJECT_TYPES[*]}"
        
        sed -i '' \
            -e "s/<PROJECTTYPE>/$PRIMARY_PROJECT_TYPE/g" \
            -e "s/<DIRECTORY_NAME>/$DIRECTORY/g" \
            -e "s/<ADDITIONAL_TYPES>/$additional_types_str/g" \
            -e "s/<ALL_TYPES>/$all_types_str/g" \
            "$file" 2>/dev/null
        
        echo "    ✓ Created ${file} from template"
    else
        echo "    ❌ Failed to download template from ${template_url}"
        return 1
    fi
}

# Function to configure VS Code settings
configure_vscode_workspace() {
    local project_dir="$1"
    local settings_dir="${project_dir}/.vscode"
    local settings_file="${settings_dir}/settings.json"
    local template_url="${BASE_URL}/project_templates/.vscode/settings.json"
    
    # Create .vscode directory if it doesn't exist
    mkdir -p "$settings_dir"
    
    # Try to download template first, fallback to default if not available
    if curl -sSL --fail "$template_url" -o "$settings_file" 2>/dev/null; then
        # Apply template substitutions
        sed -i '' \
            -e "s/<PROJECTTYPE>/$PRIMARY_PROJECT_TYPE/g" \
            -e "s/<DIRECTORY_NAME>/$DIRECTORY/g" \
            "$settings_file" 2>/dev/null
        
        echo "    ✓ Created .vscode/settings.json from template"
    else
        # Fallback to default settings if template not available
        cat > "$settings_file" << 'EOF'
{
    "github.copilot.enable": true,
    "github.copilot.advanced": {
        "referenceFiles": [
            "reference-docs/**/*.md",
            "reference-docs/**/*.txt"
        ]
    },
    "agentOS.commands.paths": {
        "common": "reference-docs/commands/common",
        "projectSpecific": "reference-docs/commands/project-specific"
    },
    "agentOS.prompts.paths": {
        "common": "reference-docs/prompts/common",
        "projectSpecific": "reference-docs/prompts/project-specific"
    }
}
EOF
        echo "    ✓ Created .vscode/settings.json with default settings"
    fi
}

# Function to set up VS Code command integration
setup_vscode_commands() {
    local project_dir="$1"
    local commands_dir="${project_dir}/reference-docs/commands"
    
    # Check if commands directory exists
    if [ ! -d "$commands_dir" ]; then
        echo "⚠️ Warning: Commands directory not found at: $commands_dir"
        return 1
    fi
    
    return 0
}

# Call the main IDE setup function
ide_setup
