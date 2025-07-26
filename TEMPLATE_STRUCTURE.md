# Template Structure for GitHub Repository

This document outlines the expected template structure for the projectai GitHub repository.

## Repository Structure

```
project_templates/
├── .github/
│   └── instructions/
│       └── template.instructions.md
├── .vscode/
│   ├── template.code-workspace
│   ├── settings.json
│   ├── tasks.json
│   └── launch.json
├── docs/
│   └── README.template.md
├── src/
│   └── example.template.js
└── [other template directories]/
    └── [template files]
```

## Template Processing

### Main Script Processing
The main `projectai.sh` script processes most template directories using curl:
- Downloads files matching patterns: `*.md`, `*.json`, `*.yaml`, `*.yml`
- Applies standard replacements: `<PROJECTTYPE>`, `<DIRECTORY_NAME>`, `<ADDITIONAL_TYPES>`, `<ALL_TYPES>`

### IDE-Specific Processing
IDE handlers process their own template directories:

#### VS Code Handler (`ide_specific/vscode.sh`)
- Processes `project_templates/.vscode/` directory
- Downloads `.code-workspace` files and renames `template.code-workspace` to `{DIRECTORY}.code-workspace`
- Downloads other VS Code files (`.json`, `.md`) to `.vscode/` directory
- Applies same replacements as main script

#### Claude/Cursor Handlers
- Generate instruction files directly (no template downloading)
- Use project variables to create customized instruction content

## Template File Placeholders

All template files can use these placeholders:
- `<PROJECTTYPE>` - Primary project type (e.g., "drupal")
- `<DIRECTORY_NAME>` - Project directory name
- `<ADDITIONAL_TYPES>` - Space-separated additional project types
- `<ALL_TYPES>` - Space-separated all project types (primary + additional)

## Curl-Based Installation

The system uses curl to download templates directly from GitHub, similar to agent-os:
```bash
curl -sSL https://raw.githubusercontent.com/jdelon02/agent-os/main/project_templates/...
```

This allows the script to be run from anywhere without local template files.
