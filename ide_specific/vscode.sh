#!/bin/bash

# VS Code IDE specific instruction file generator
# This file contains the logic for creating .github/instructions/main.instructions.md files
# and handling VS Code workspace files

# Function to create VS Code workspace file from template
create_vscode_workspace_file() {
    echo "    📁 Setting up VS Code workspace file..."
    
    # Check if .vscode template directory exists and get its files
    local vscode_template_dir="${BASE_URL}/project_templates/.vscode/"
    
    if check_curl "$vscode_template_dir" ".vscode template directory"; then
        # Get list of files in the .vscode template directory
        local template_files
        template_files=$(curl -s "${vscode_template_dir}" 2>/dev/null | grep -o '"[^"]*\.code-workspace"' | tr -d '"') || {
            echo "    ⚠️  Failed to list .vscode template files"
            return 1
        }
        
        if [ -z "$template_files" ]; then
            echo "    ℹ️  No .code-workspace template files found"
            return 0
        fi
        
        # Process each .code-workspace file found
        for template_file in $template_files; do
            echo "    ⬇️  Downloading ${template_file}..."
            
            # Create .vscode directory
            mkdir -p "${FULL_PATH}/.vscode"
            
            # Determine target filename (rename template.code-workspace to {DIRECTORY}.code-workspace)
            local target_file
            if [[ "$template_file" == "template.code-workspace" ]]; then
                target_file="${DIRECTORY}.code-workspace"
            else
                target_file="$template_file"
            fi
            
            local workspace_file="${FULL_PATH}/.vscode/${target_file}"
            local template_url="${vscode_template_dir}${template_file}"
            
            # Download the template file
            if curl -s --fail -o "$workspace_file" "$template_url" 2>/dev/null; then
                if [ -f "$workspace_file" ]; then
                    # Customize the workspace file with project-specific values
                    local additional_types_str="${ADDITIONAL_PROJECT_TYPES[*]}"
                    local all_types_str="${ALL_PROJECT_TYPES[*]}"
                    
                    if sed -i '' \
                        -e "s/<PROJECTTYPE>/$PRIMARY_PROJECT_TYPE/g" \
                        -e "s/<DIRECTORY_NAME>/$DIRECTORY/g" \
                        -e "s/<ADDITIONAL_TYPES>/$additional_types_str/g" \
                        -e "s/<ALL_TYPES>/$all_types_str/g" \
                        "$workspace_file" 2>/dev/null; then
                        echo "    ✓ Created and customized VS Code workspace file: ${target_file}"
                    else
                        echo "    ⚠️  Failed to customize VS Code workspace file: ${target_file}"
                        rm -f "$workspace_file"
                    fi
                fi
            else
                echo "    ⚠️  Failed to download VS Code workspace template: ${template_file}"
            fi
        done
        
        return 0
    else
        echo "    ℹ️  No .vscode template directory found, skipping workspace file creation..."
        return 0
    fi
}

# Function to download and process other VS Code-specific template files
create_vscode_template_files() {
    echo "    📁 Setting up additional VS Code template files..."
    
    # Check if .vscode template directory exists
    local vscode_template_dir="${BASE_URL}/project_templates/.vscode/"
    
    if check_curl "$vscode_template_dir" ".vscode template directory"; then
        # Get list of all files in .vscode template directory (excluding .code-workspace files)
        local template_files
        template_files=$(curl -s "${vscode_template_dir}" 2>/dev/null | grep -o '"[^"]*\.\(json\|md\)"' | tr -d '"') || {
            echo "    ⚠️  Failed to list .vscode template files"
            return 1
        }
        
        if [ -z "$template_files" ]; then
            echo "    ℹ️  No additional .vscode template files found"
            return 0
        fi
        
        # Create .vscode directory
        mkdir -p "${FULL_PATH}/.vscode"
        
        # Process each template file
        for template_file in $template_files; do
            echo "    ⬇️  Downloading ${template_file}..."
            
            local target_file="$template_file"
            local target_path="${FULL_PATH}/.vscode/${target_file}"
            local template_url="${vscode_template_dir}${template_file}"
            
            # Download the template file
            if curl -s --fail -o "$target_path" "$template_url" 2>/dev/null; then
                if [ -f "$target_path" ]; then
                    # Customize the file with project-specific values
                    local additional_types_str="${ADDITIONAL_PROJECT_TYPES[*]}"
                    local all_types_str="${ALL_PROJECT_TYPES[*]}"
                    
                    if sed -i '' \
                        -e "s/<PROJECTTYPE>/$PRIMARY_PROJECT_TYPE/g" \
                        -e "s/<DIRECTORY_NAME>/$DIRECTORY/g" \
                        -e "s/<ADDITIONAL_TYPES>/$additional_types_str/g" \
                        -e "s/<ALL_TYPES>/$all_types_str/g" \
                        "$target_path" 2>/dev/null; then
                        echo "    ✓ Created and customized VS Code file: ${target_file}"
                    else
                        echo "    ⚠️  Failed to customize VS Code file: ${target_file}"
                        rm -f "$target_path"
                    fi
                fi
            else
                echo "    ⚠️  Failed to download VS Code template: ${template_file}"
            fi
        done
        
        return 0
    else
        echo "    ℹ️  No .vscode template directory found, skipping additional files..."
        return 0
    fi
}

create_vscode_instruction_file() {
    local project_types_display="$1"
    
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
    
    echo "    ✓ Created .github/instructions/main.instructions.md file with ${#ALL_PROJECT_TYPES[@]} project type(s)"
    
    # Also create VS Code workspace file
    create_vscode_workspace_file
    
    # Create additional VS Code template files (settings.json, tasks.json, etc.)
    create_vscode_template_files
    
    return 0
}
