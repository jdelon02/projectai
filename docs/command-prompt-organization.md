# Command and Prompt Organization

This document describes the organization of commands and prompts in Agent OS projects.

## Directory Structure

When a project is initialized, the following structure is created via symlinks to ~/.agent-os:

```
reference-docs/
├── commands/                 # Source of truth for commands
│   ├── common/              # Shared commands
│   └── project-specific/    # Project type specific commands
├── prompts/                 # Source of truth for prompts
│   ├── common/              # Shared prompts
│   └── project-specific/    # Project type specific prompts
└── [other directories...]
```

## IDE Integration

Different IDEs access these resources in different ways:

1. **VS Code**
   - Prompts: Via `.github/prompts` → `reference-docs/prompts` symlink
   - Commands: Configured in `.vscode/settings.json`

2. **Claude**
   - Direct references to files in `reference-docs/` directory
   - Paths documented in `CLAUDE.md`

3. **Cursor**
   - Both commands and prompts configured in `.cursorrules`
   - Uses relative paths to `reference-docs/`

## Maintenance Guidelines

1. **Source of Truth**
   - All commands and prompts should be managed in `~/.agent-os/`
   - Never modify files directly in `reference-docs/` as they are symlinks

2. **Adding New Content**
   - Add new commands to `~/.agent-os/commands/{common,project-specific}/`
   - Add new prompts to `~/.agent-os/prompts/{common,project-specific}/`
   - Use the maintenance script: `./scripts/maintenance.sh`

3. **Best Practices**
   - Always use relative paths
   - Update IDE configurations when adding new content
   - Follow the established directory structure
   - Keep project-specific content separate from common content

4. **Updating Projects**
   - Run `projectai --update-symlinks` to refresh symlinks
   - Verify IDE configurations are up to date
   - Test command and prompt access in each IDE
