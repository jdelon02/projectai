#!/bin/bash

# VS Code IDE specific instruction file generator
# This file contains the logic for creating .github/instructions/main.instructions.md files
# and handling VS Code workspace files

# Main setup function called by projectai.sh
ide_setup() {
    local project_types_display
    if [ ${#ALL_PROJECT_TYPES[@]} -eq 1 ]; then
        project_types_display="$PRIMARY_PROJECT_TYPE"
    else
        project_types_display="$PRIMARY_PROJECT_TYPE (+ ${ADDITIONAL_PROJECT_TYPES[*]})"
    fi

    # Create instruction files
    create_vscode_instruction_file "$project_types_display" || return 1
    
    # Report success
    echo "✓ VS Code setup completed successfully"
    return 0
}

# Function to create VS Code workspace file from main template
create_vscode_workspace_file() {
    echo "    📁 Setting up VS Code workspace file..."
    mkdir -p "${FULL_PATH}/.vscode"
    local workspace_file="${FULL_PATH}/.vscode/${DIRECTORY}.code-workspace"
    local template_url="${BASE_URL}/project_templates/.vscode/template.code-workspace"
    if curl -s --fail -o "$workspace_file" "$template_url" 2>/dev/null; then
        if [ -f "$workspace_file" ]; then
            local additional_types_str="${ADDITIONAL_PROJECT_TYPES[*]}"
            local all_types_str="${ALL_PROJECT_TYPES[*]}"
            if sed -i '' \
                -e "s/<PROJECTTYPE>/$PRIMARY_PROJECT_TYPE/g" \
                -e "s/<DIRECTORY_NAME>/$DIRECTORY/g" \
                -e "s/<ADDITIONAL_TYPES>/$additional_types_str/g" \
                -e "s/<ALL_TYPES>/$all_types_str/g" \
                "$workspace_file" 2>/dev/null; then
                echo "    ✓ Created and customized VS Code workspace file: ${DIRECTORY}.code-workspace"
            else
                echo "    ⚠️  Failed to customize VS Code workspace file: ${DIRECTORY}.code-workspace"
                rm -f "$workspace_file"
            fi
        fi
    else
        echo "    ⚠️  Failed to download VS Code workspace template: ${template_url}"
    fi
    return 0
}


# Additional VS Code template files should be placed in project_templates/.vscode
# Examples: settings.json, tasks.json, launch.json, extensions.json
create_vscode_template_files() {
    local vscode_dir="${FULL_PATH}/.vscode"
    mkdir -p "$vscode_dir"
    
    # Array of potential template files to copy
    local template_files=("settings.json" "tasks.json" "launch.json" "extensions.json")
    
    for template in "${template_files[@]}"; do
        local template_url="${BASE_URL}/project_templates/.vscode/${template}"
        local target_file="${vscode_dir}/${template}"
        
        if curl -s --fail -o "$target_file" "$template_url" 2>/dev/null; then
            if [ -f "$target_file" ]; then
                # Apply any template replacements if needed
                sed -i '' \
                    -e "s/<PROJECTTYPE>/$PRIMARY_PROJECT_TYPE/g" \
                    -e "s/<DIRECTORY_NAME>/$DIRECTORY/g" \
                    "$target_file" 2>/dev/null
                echo "    ✓ Created .vscode/${template}"
            fi
        fi
    done
    return 0
}

create_vscode_instruction_file() {
    local project_types_display="$1"

    local instructions_dir="$FULL_PATH/.github/instructions"
    mkdir -p "$instructions_dir"
    local instruction_file="$instructions_dir/main.instructions.md"
    local instruction_template_url="${BASE_URL}/project_templates/.github/instructions/main.instructions.md"
    if ! curl -s --fail -o "$instruction_file" "$instruction_template_url" 2>/dev/null; then
        # Try local template first
        local local_template="$SCRIPT_DIR/project_templates/.github/instructions/main.instructions.md"
        if [ -f "$local_template" ]; then
            cp "$local_template" "$instruction_file"
        else
            echo "    ⚠️  Failed to download or find main.instructions.md template"
            return 1
        fi
    fi

    if [ -f "$instruction_file" ]; then
        local additional_types_str="${ADDITIONAL_PROJECT_TYPES[*]}"
        local all_types_str="${ALL_PROJECT_TYPES[*]}"
        if ! sed -i '' \
            -e "s/<PROJECTTYPE>/$PRIMARY_PROJECT_TYPE/g" \
            -e "s/<DIRECTORY_NAME>/$DIRECTORY/g" \
            -e "s/<ADDITIONAL_TYPES>/$additional_types_str/g" \
            -e "s/<ALL_TYPES>/$all_types_str/g" \
            -e "s/<FULL_PATH>/$FULL_PATH/g" \
            "$instruction_file" 2>/dev/null; then
            echo "    ⚠️  Failed to customize main.instructions.md"
            return 1
        fi
        echo "    ✓ Created .github/instructions/main.instructions.md file with ${#ALL_PROJECT_TYPES[@]} project type(s)"
    else
        echo "    ⚠️  Failed to create main.instructions.md"
        return 1
    fi

    # Download copilot-instructions.md from template repo
    local copilot_file="$FULL_PATH/.github/copilot-instructions.md"
    local copilot_template_url="${BASE_URL}/project_templates/.github/copilot-instructions.md"
    mkdir -p "$FULL_PATH/.github"
    if curl -s --fail -o "$copilot_file" "$copilot_template_url" 2>/dev/null; then
        if [ -f "$copilot_file" ]; then
            sed -i '' -e "s/<INSTRUCTIONS_PATH>/.github/instructions/main.instructions.md/g" "$copilot_file" 2>/dev/null
            echo "    ✓ Created .github/copilot-instructions.md file"
        fi
    else
        echo "    ⚠️  Failed to download copilot-instructions.md template: ${copilot_template_url}"
    fi

    # Also create VS Code workspace file
    create_vscode_workspace_file
    # Create additional VS Code template files (settings.json, tasks.json, etc.)
    create_vscode_template_files
    return 0
}
