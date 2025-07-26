#!/bin/bash

# Claude IDE specific instruction file generator
# This file contains the logic for creating CLAUDE.md instruction files

create_claude_instruction_file() {
    local project_types_display="$1"
    local instruction_file="$FULL_PATH/CLAUDE.md"
    
    cat > "$instruction_file" << EOF
# CLAUDE.md

> Agent OS Project Instructions
> Primary Project Type: $PRIMARY_PROJECT_TYPE
> Additional Types: ${ADDITIONAL_PROJECT_TYPES[*]}
> Directory: $DIRECTORY
> Generated: $(date +"%Y-%m-%d")

## Purpose

This file directs Claude Code to use your Agent OS standards for this multi-type project ($project_types_display). These instructions reference your global Agent OS installation and provide project-specific context.

## Primary Project Standards ($PRIMARY_PROJECT_TYPE)

### Development Standards
- **Tech Stack Defaults:** @~/.agent-os/$PRIMARY_PROJECT_TYPE/tech-stack.md
- **Code Style Preferences:** @~/.agent-os/$PRIMARY_PROJECT_TYPE/code-style.md
- **Best Practices Philosophy:** @~/.agent-os/$PRIMARY_PROJECT_TYPE/best-practices.md
- **Main Instructions:** @~/.agent-os/$PRIMARY_PROJECT_TYPE/main.instructions.md

## Additional Technology Standards

EOF
    
    # Add references for additional project types
    for project_type in "${ADDITIONAL_PROJECT_TYPES[@]}"; do
        cat >> "$instruction_file" << EOF
### $project_type Standards
- **Tech Stack:** @~/.agent-os/$project_type/tech-stack.md
- **Code Style:** @~/.agent-os/$project_type/code-style.md
- **Best Practices:** @~/.agent-os/$project_type/best-practices.md
- **Instructions:** @~/.agent-os/$project_type/main.instructions.md

EOF
    done
    
    cat >> "$instruction_file" << EOF
## Agent OS Instructions
- **Initialize Products:** @~/.agent-os/instructions/plan-product.md
- **Plan Features:** @~/.agent-os/instructions/create-spec.md
- **Execute Tasks:** @~/.agent-os/instructions/execute-tasks.md
- **Analyze Existing Code:** @~/.agent-os/instructions/analyze-product.md

## Project Context

- **Primary Type:** $PRIMARY_PROJECT_TYPE
- **Additional Types:** ${ADDITIONAL_PROJECT_TYPES[*]}
- **Directory Name:** $DIRECTORY
- **Full Path:** $FULL_PATH

## Using Agent OS Commands

You can invoke Agent OS commands directly:
- \`/plan-product\` - Start planning this product
- \`/create-spec\` - Plan a new feature for this project
- \`/execute-task\` - Build and ship code for this project
- \`/analyze-product\` - Analyze this existing codebase

## Important Notes

- Primary standards from \`~/.agent-os/$PRIMARY_PROJECT_TYPE/\` take precedence
- Additional technology standards provide supplementary guidance
- Project-specific files in this directory override global defaults
- Update Agent OS standards as you discover new patterns

---

*Using Agent OS for structured AI-assisted development. Learn more at [buildermethods.com/agent-os](https://buildermethods.com/agent-os)*
EOF
    
    echo "    ✓ Created CLAUDE.md instruction file with ${#ALL_PROJECT_TYPES[@]} project type(s)"
    return 0
}
