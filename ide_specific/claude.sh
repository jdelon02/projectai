#!/bin/bash

# Claude IDE specific instruction file generator
# This file contains the logic for creating CLAUDE.md instruction files

# Main setup function called by projectai.sh
ide_setup() {
    local project_types_display
    if [ ${#ALL_PROJECT_TYPES[@]} -eq 1 ]; then
        project_types_display="$PRIMARY_PROJECT_TYPE"
    else
        project_types_display="$PRIMARY_PROJECT_TYPE (+ ${ADDITIONAL_PROJECT_TYPES[*]})"
    fi

    # Create Claude instruction file
    if ! create_claude_instruction_file "$project_types_display"; then
        return 1
    fi
    
    # Report success
    echo "✓ Claude setup completed successfully"
    return 0
}

create_claude_instruction_file() {
    local project_types_display="$1"
    local instruction_file="$FULL_PATH/CLAUDE.md"
    local template_url="${BASE_URL}/project_templates/claude-code/CLAUDE.md"

    if curl -s --fail -o "$instruction_file" "$template_url" 2>/dev/null; then
        if [ -f "$instruction_file" ]; then
            local additional_sections=""
            for project_type in "${ADDITIONAL_PROJECT_TYPES[@]}"; do
                additional_sections+="### $project_type Standards"$'\n'
                additional_sections+="- **Tech Stack:** @~/.agent-os/$project_type/tech-stack.md"$'\n'
                additional_sections+="- **Code Style:** @~/.agent-os/$project_type/code-style.md"$'\n'
                additional_sections+="- **Best Practices:** @~/.agent-os/$project_type/best-practices.md"$'\n'
                additional_sections+="- **Instructions:** @~/.agent-os/$project_type/main.instructions.md"$'\n'$'\n'
            done

            # Create replacement strings
            local additional_types_str="${ADDITIONAL_PROJECT_TYPES[*]}"
            local all_types_str="${ALL_PROJECT_TYPES[*]}"

            if sed -i '' \
                -e "s/<PROJECTTYPE>/$PRIMARY_PROJECT_TYPE/g" \
                -e "s/<DIRECTORY_NAME>/$DIRECTORY/g" \
                -e "s/<ADDITIONAL_TYPES>/$additional_types_str/g" \
                -e "s/<ALL_TYPES>/$all_types_str/g" \
                -e "s/<PROJECT_TYPES_DISPLAY>/$project_types_display/g" \
                -e "s/<ADDITIONAL_SECTIONS>/$additional_sections/g" \
                "$instruction_file" 2>/dev/null; then
                echo "    ✓ Created and customized CLAUDE.md file with ${#ALL_PROJECT_TYPES[@]} project type(s)"
            else
                echo "    ⚠️  Created CLAUDE.md but failed to customize placeholders"
            fi
        fi
    else
        echo "    ⚠️  Failed to download CLAUDE.md template, creating basic version"
        # Fallback to a simple version if template download fails
        cat > "$instruction_file" << EOF
# CLAUDE.md

This is a **$PRIMARY_PROJECT_TYPE** project using Agent OS structured development workflows.

For complete instructions, see: \`~/.agent-os/$PRIMARY_PROJECT_TYPE/main.instructions.md\`
EOF
    fi
    
    return 0
}
