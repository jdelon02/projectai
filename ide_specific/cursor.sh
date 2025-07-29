#!/bin/bash

# Cursor IDE specific instruction file generator
# This file contains the logic for creating .cursorrules files

# Main setup function called by projectai.sh
ide_setup() {
    # Create Cursor instruction file
    if ! create_cursor_instruction_file; then
        return 1
    fi
    
    # Report success
    echo "✓ Cursor IDE setup completed successfully"
    return 0
}

create_cursor_instruction_file() {
    local project_types_display="$1"
    local instruction_file="$FULL_PATH/.cursorrules"
    local template_url="${BASE_URL}/project_templates/cursor-ide/.cursorrules"

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
