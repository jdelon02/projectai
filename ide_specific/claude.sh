#!/bin/bash

# Claude IDE specific instruction file generator
# This file contains the logic for creating CLAUDE.md instruction files

# Function to generate CLAUDE.md with proper references
generate_claude_md() {
    local project_dir="$1"
    local claude_file="${project_dir}/CLAUDE.md"
    
    cat > "$claude_file" << 'EOF'
# Claude Code Instructions

This project uses Agent OS for structured development. All commands and prompts are available in the reference-docs directory.

## Command Organization

Commands are organized in the following directories:
- **Common Commands** (`./reference-docs/commands/common/`):
  - General development workflows
  - Source control operations
  - File and directory management
  - Build and test runners

- **Project-Specific Commands** (`./reference-docs/commands/project-specific/`):
  - Framework-specific commands
  - Language-specific operations
  - Project type tooling commands
  - Custom build and deployment scripts

## Prompt Organization

Prompts are organized in the following directories:
- **Common Prompts** (`./reference-docs/prompts/common/`):
  - Development workflow prompts
  - Code review templates
  - Documentation templates
  - Testing guidelines

- **Project-Specific Prompts** (`./reference-docs/prompts/project-specific/`):
  - Framework-specific templates
  - Language-specific guides
  - Project type conventions
  - Custom workflow templates

## Project Standards

Project standards and documentation can be found in:
- ./reference-docs/standards/
- ./reference-docs/instructions/

## Additional Resources

- Chatmodes: ./reference-docs/chatmodes/
- Project-specific documentation: Check respective project type directories in reference-docs/
EOF
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
    
    # Generate CLAUDE.md with proper references
    if ! generate_claude_md "$project_dir"; then
        echo "❌ Error: Failed to generate CLAUDE.md"
        return 1
    fi
    
    # Configure command and prompt integration
    if ! setup_claude_commands "$project_dir"; then
        echo "⚠️ Warning: Command integration setup incomplete"
    fi
    
    echo "✅ Claude Code environment setup complete"
    return 0

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
