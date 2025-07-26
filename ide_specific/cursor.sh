#!/bin/bash

# Cursor IDE specific instruction file generator
# This file contains the logic for creating .cursorrules files

create_cursor_instruction_file() {
    local project_types_display="$1"
    local instruction_file="$FULL_PATH/.cursorrules"
    
    cat > "$instruction_file" << EOF
# Cursor IDE Rules - Agent OS Project

# Primary Project Type: $PRIMARY_PROJECT_TYPE
# Additional Types: ${ADDITIONAL_PROJECT_TYPES[*]}
# Directory: $DIRECTORY
# Generated: $(date +"%Y-%m-%d")

# Agent OS Standards
You are working on a $PRIMARY_PROJECT_TYPE project with additional technologies (${ADDITIONAL_PROJECT_TYPES[*]}) using Agent OS structured development methodology.

## Primary Reference Files ($PRIMARY_PROJECT_TYPE)
- Main Instructions: ~/.agent-os/$PRIMARY_PROJECT_TYPE/main.instructions.md
- Tech Stack Standards: ~/.agent-os/$PRIMARY_PROJECT_TYPE/tech-stack.md
- Code Style Guide: ~/.agent-os/$PRIMARY_PROJECT_TYPE/code-style.md
- Best Practices: ~/.agent-os/$PRIMARY_PROJECT_TYPE/best-practices.md

EOF
    
    # Add references for additional project types
    for project_type in "${ADDITIONAL_PROJECT_TYPES[@]}"; do
        cat >> "$instruction_file" << EOF
## Additional Standards ($project_type)
- Instructions: ~/.agent-os/$project_type/main.instructions.md
- Tech Stack: ~/.agent-os/$project_type/tech-stack.md
- Code Style: ~/.agent-os/$project_type/code-style.md
- Best Practices: ~/.agent-os/$project_type/best-practices.md

EOF
    done
    
    cat >> "$instruction_file" << EOF
## Development Approach
1. Always reference the Agent OS standards, prioritizing $PRIMARY_PROJECT_TYPE as primary
2. Apply additional technology standards as supplementary guidance
3. Follow spec-driven development - plan before implementing
4. Maintain clean, modular architecture
5. Document architectural decisions
6. Follow the established conventions for all referenced technologies

## Project Context
- Primary Type: $PRIMARY_PROJECT_TYPE
- Additional Types: ${ADDITIONAL_PROJECT_TYPES[*]}
- Name: $DIRECTORY
- Path: $FULL_PATH

## Agent OS Workflow Integration
- Plan products using ~/.agent-os/instructions/plan-product.md
- Create specifications with ~/.agent-os/instructions/create-spec.md
- Execute tasks following ~/.agent-os/instructions/execute-tasks.md
- Analyze code using ~/.agent-os/instructions/analyze-product.md

Always prioritize code quality, maintainability, and adherence to the established Agent OS standards for this multi-technology project.
EOF
    
    echo "    ✓ Created .cursorrules file with ${#ALL_PROJECT_TYPES[@]} project type(s)"
    return 0
}
