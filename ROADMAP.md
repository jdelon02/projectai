# ProjectAI Symlink Enhancement Roadmap

## Overview

Enhance ProjectAI to automatically create symbolic links to Agent OS directories, making project type-specific instructions and global Agent OS resources available within each project workspace.

## Implementation Plan

### 1. Global Agent OS Directory Symlinks

#### Modify `projectai.sh` to add global symlink creation:

```bash
create_global_symlinks() {
    local project_dir="$1"
    local global_dirs=("standards" "instructions" "commands" "chatmodes" "prompts")
    
    # Create reference-docs directory in project
    mkdir -p "${project_dir}/reference-docs"
    
    # Create symlinks for global directories
    for dir in "${global_dirs[@]}"; do
        if [ -d "${HOME}/.agent-os/${dir}" ]; then
            ln -sf "${HOME}/.agent-os/${dir}" "${project_dir}/reference-docs/${dir}"
        else
            echo "⚠️ Warning: ${HOME}/.agent-os/${dir} not found"
        fi
    done
}
```

### 2. Project Type-Specific Symlinks

#### Add function to `projectai.sh` for project type symlinks:

```bash
create_project_type_symlinks() {
    local project_dir="$1"
    shift
    local project_types=("$@")
    
    # Create reference-docs directory for project type symlinks
    mkdir -p "${project_dir}/reference-docs"
    
    # Create symlinks for each project type
    for type in "${project_types[@]}"; do
        # Convert to lowercase for consistency
        type_lower=$(echo "$type" | tr '[:upper:]' '[:lower:]')
        
        if [ -d "${HOME}/.agent-os/${type_lower}" ]; then
            ln -sf "${HOME}/.agent-os/${type_lower}" "${project_dir}/reference-docs/${type_lower}"
        else
            echo "⚠️ Warning: ${HOME}/.agent-os/${type_lower} not found"
        fi
    done
}
```

### 3. Integration Points

1. Update `projectai.sh` main flow for GitHub deployment:
   ```bash
   # IMPORTANT: projectai.sh must remain IDE-agnostic
   # Only handle project setup and symlink creation here
   
   # Define base URL for GitHub raw content
   BASE_URL="https://raw.githubusercontent.com/jdelon02/projectai/main"
   
   # Create symlinks first
   create_global_symlinks "$PROJECT_DIR"
   
   # Handle project types
   IFS=',' read -ra PROJECT_TYPES <<< "$1"
   create_project_type_symlinks "$PROJECT_DIR" "${PROJECT_TYPES[@]}"
   
   # Download and source IDE-specific setup script
   IDE_SCRIPT_URL="${BASE_URL}/ide_specific/${SELECTED_IDE}.sh"
   IDE_SCRIPT_CONTENT=$(curl -sSL "$IDE_SCRIPT_URL")
   
   if [ $? -eq 0 ] && [ ! -z "$IDE_SCRIPT_CONTENT" ]; then
       # Create temporary file for IDE script
       TMP_SCRIPT=$(mktemp)
       echo "$IDE_SCRIPT_CONTENT" > "$TMP_SCRIPT"
       
       # Source the IDE-specific script
       source "$TMP_SCRIPT"
       setup_ide_environment "$PROJECT_DIR" "${PROJECT_TYPES[@]}"
       
       # Cleanup
       rm "$TMP_SCRIPT"
   else
       echo "❌ Error: Could not download IDE setup script from: $IDE_SCRIPT_URL"
       exit 1
   fi
   ```

2. GitHub-Based IDE Script Integration:
   - Keep `projectai.sh` focused on core functionality:
     - Project directory creation
     - Symlink management
     - Project type validation
     - Error handling
     - Downloading IDE-specific scripts
   - Move ALL IDE-specific logic to dedicated scripts in GitHub repository:
     - `ide_specific/vscode.sh` for VS Code setup
     - `ide_specific/claude.sh` for Claude setup
     - `ide_specific/cursor.sh` for Cursor setup
   - Each IDE script must:
     - Be self-contained (no external dependencies)
     - Implement `setup_ide_environment()` function
     - Handle command/prompt configuration
     - Download and generate necessary templates
     - Be accessible via GitHub raw content URLs

### 4. Error Handling

Add checks for:
- Existing symlinks
- Invalid project types
- Missing source directories
- Symlink creation permissions

### 5. IDE-Specific Integration

#### Separation of Concerns

- Keep `projectai.sh` IDE-agnostic
- Move all IDE-specific functionality to dedicated scripts in `ide_specific/` directory:
  ```
  ide_specific/
  ├── vscode.sh      # VS Code/GitHub Copilot specific setup
  ├── claude.sh      # Claude Code specific setup
  ├── cursor.sh      # Cursor IDE specific setup
  └── README.md      # Documentation for adding new IDE support
  ```

#### IDE-Specific Setup Scripts

1. **VS Code Setup (`ide_specific/vscode.sh`)**
   ```bash
   setup_vscode_environment() {
     # Create symlink for prompts
     ln -sf "${PROJECT_DIR}/reference-docs/prompts" "${PROJECT_DIR}/.github/prompts"
     
     # Configure command integration
     setup_vscode_commands
     
     # Update workspace settings
     configure_vscode_workspace
   }
   ```

2. **Claude Setup (`ide_specific/claude.sh`)**
   ```bash
   setup_claude_environment() {
     # Generate CLAUDE.md with proper references
     generate_claude_md
     
     # Configure command and prompt integration
     setup_claude_commands
   }
   ```

3. **Cursor Setup (`ide_specific/cursor.sh`)**
   ```bash
   setup_cursor_environment() {
     # Generate .cursorrules with proper configurations
     generate_cursor_rules
     
     # Set up command and prompt integration
     setup_cursor_integrations
   }
   ```

#### Command and Prompt Integration by IDE

1. **VS Code/GitHub Copilot**
   - Commands configured in `.vscode/settings.json`
   - Prompts accessible via `.github/prompts` symlink
   - Template updates handled by `vscode.sh`

2. **Claude Code**
   - Command and prompt references in `CLAUDE.md`
   - Auto-generated by `claude.sh` from templates
   - Uses relative paths to `reference-docs/`

3. **Cursor IDE**
   - Configurations in `.cursorrules`
   - Generated by `cursor.sh` from templates
   - References content from `reference-docs/`

### 6. Command and Prompt Organization

1. **Directory Structure**
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

2. **Symlink Strategy**
   - VS Code:
     - `.github/prompts` → `reference-docs/prompts`
     - Commands configured via settings
   - Claude:
     - Commands and prompts referenced directly
   - Cursor:
     - Commands and prompts configured in .cursorrules

3. **Maintenance Workflow**
   - Keep source files in `reference-docs/`
   - Update IDE-specific configurations when adding new commands/prompts
   - Use relative paths to maintain portability

## Testing Plan

1. Test symlink creation:
   ```bash
   projectai "drupal,wordpress,laravel"
   ```
   Verify:
   - `reference-docs/{standards,instructions,commands,chatmodes,prompts}` symlinks exist
   - `reference-docs/{drupal,wordpress,laravel}` symlinks exist

2. Test different combinations:
   - Single project type
   - Multiple project types
   - Invalid project types
   - Missing source directories

## Documentation Updates

1. Update README.md:
   - Add section about symlinked directories
   - Document directory structure changes
   - Update troubleshooting section

2. Update IDE-specific documentation:
   - Document symlink locations
   - Explain how to reference symlinked files

## Implementation Phases

### Phase 1: Core Symlink Functionality
- [ ] Implement `create_global_symlinks`
- [ ] Implement `create_project_type_symlinks`
- [ ] Add basic error handling
- [ ] Update main script flow

### Phase 2: IDE Integration
- [ ] Update VS Code template handling
- [ ] Update Claude Code template
- [ ] Update Cursor IDE configuration
- [ ] Test cross-IDE compatibility

### Phase 3: Documentation & Testing
- [ ] Update README.md
- [ ] Update IDE-specific docs
- [ ] Create test cases
- [ ] Document edge cases

### Phase 4: Optimization & Enhancement
- [ ] Add symlink validation
- [ ] Implement cleanup for removed project types
- [ ] Add symlink status command
- [ ] Create symlink repair functionality

## Migration Guide

For existing projects:
1. Run symlink creation manually:
   ```bash
   projectai --update-symlinks
   ```
2. Update IDE configurations to use new symlink paths
3. Verify all references work correctly

## Future Enhancements

1. Add command to update symlinks:
   ```bash
   projectai --update-symlinks
   ```

2. Add symlink status check:
   ```bash
   projectai --check-symlinks
   ```

3. Consider adding:
   - Symlink repair command
   - Custom symlink mappings
   - Symlink path configuration
   - Automated symlink verification
