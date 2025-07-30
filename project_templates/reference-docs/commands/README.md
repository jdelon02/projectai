# Commands Directory

This directory is the source of truth for all Agent OS commands. The structure is organized to separate common commands from project-specific ones.

## Directory Structure

- `common/`: Commands that are available across all project types
- `project-specific/`: Commands that are specific to certain project types

## Command Types

1. **Common Commands**
   - Generic development workflow commands
   - Source control operations
   - File and directory management
   - Build and test runners

2. **Project-Specific Commands**
   - Framework-specific commands
   - Language-specific operations
   - Project type tooling commands
   - Custom build and deployment scripts

## Integration

Each IDE accesses these commands differently:
- VS Code: Via `.vscode/settings.json`
- Claude: Direct references in `CLAUDE.md`
- Cursor: Configuration in `.cursorrules`

## Maintenance

1. Always add new commands to the appropriate directory
2. Keep command names consistent across IDEs
3. Use relative paths when referencing commands
4. Update IDE configurations when adding new commands
