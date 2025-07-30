# Prompts Directory

This directory is the source of truth for all Agent OS prompts. The structure separates common prompts from project-specific ones.

## Directory Structure

- `common/`: Prompts that are available across all project types
- `project-specific/`: Prompts that are specific to certain project types

## Prompt Types

1. **Common Prompts**
   - Development workflow prompts
   - Code review templates
   - Documentation templates
   - Testing guidelines

2. **Project-Specific Prompts**
   - Framework-specific templates
   - Language-specific guides
   - Project type conventions
   - Custom workflow templates

## Integration

Each IDE accesses these prompts differently:
- VS Code: Via `.github/prompts` symlink
- Claude: Direct references in `CLAUDE.md`
- Cursor: Configuration in `.cursorrules`

## Maintenance

1. Always add new prompts to the appropriate directory
2. Keep prompt names descriptive and consistent
3. Use relative paths when referencing prompts
4. Update IDE configurations when adding new prompts
