# IDE-Specific Handlers

This directory contains modular handlers for different IDEs supported by the projectai script. All handlers use curl to download template files from the GitHub repository, similar to the agent-os installation approach.

## Structure

- `claude.sh` - Handler for Claude Code IDE instruction files (CLAUDE.md)
- `vscode.sh` - Handler for VS Code with GitHub Copilot (.github/instructions/main.instructions.md and .vscode/ files)
- `cursor.sh` - Handler for Cursor IDE (.cursorrules)

## Usage

These files are automatically sourced by the main `projectai.sh` script based on the user's IDE selection. Each handler downloads and processes template files from the GitHub repository using curl.

## Template File Structure

Template files are organized by IDE in the repository:
- `project_templates/.vscode/` - VS Code specific templates (workspace files, settings, etc.)
- `project_templates/.github/` - GitHub/VS Code Copilot templates  
- Other template directories are processed by the main script

## Adding New IDEs

To add support for a new IDE:

1. Create a new file `{ide-name}.sh` in this directory
2. Implement a function named `create_{ide-name}_instruction_file()`
3. Add curl-based template downloading if the IDE needs specific template files
4. Update the IDE selection prompt in the main script
5. Add the new case to the switch statement in `create_instruction_file()`

## Function Signature

Each IDE handler should implement a function with this signature:
```bash
create_{ide-name}_instruction_file() {
    local project_types_display="$1"
    # Implementation here
    return 0
}
```

The function has access to all global variables from the main script:
- `$PRIMARY_PROJECT_TYPE`
- `$ADDITIONAL_PROJECT_TYPES[@]`
- `$ALL_PROJECT_TYPES[@]`
- `$FULL_PATH`
- `$DIRECTORY`
