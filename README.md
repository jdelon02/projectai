# ProjectAI

A powerful initialization script that extends Agent OS functionality to set up AI-assisted development projects with IDE-specific configurations, using templates from GitHub.

## Overview

ProjectAI automatically:
- 🔍 Validates your Agent OS installation and project types
- 🤖 Configures AI coding tools (Claude Code, VS Code with GitHub Copilot, or Cursor IDE)
- 📂 Downloads and customizes project templates from GitHub
- ⚙️ Sets up IDE-specific instruction files and workspace configurations
- 🔄 Supports comma-separated input for multiple project types
- 🌐 Fetches all templates from GitHub for consistency

## Prerequisites

**Agent OS must be installed first:**
```bash
curl -sSL https://raw.githubusercontent.com/jdelon02/agent-os/main/setup.sh | bash
```

## Installation

There are two main ways to install ProjectAI: **Automatic** (recommended) or **Manual**.

### 🤖 Automatic Installation (Recommended)

The easiest way is to use our auto-installer:

```bash
curl -sSL https://raw.githubusercontent.com/jdelon02/projectai/main/install.sh | bash
```

This script will:
- ✅ Detect your shell (zsh, bash, etc.)
- ✅ Add the `projectai` alias to your shell configuration
- ✅ Handle duplicate detection
- ✅ Provide clear next steps

### ⚙️ Manual Installation

If you prefer to set things up yourself, add this alias to your shell configuration:

**For Zsh users (macOS default):**
```bash
echo "alias projectai='curl -sSL https://raw.githubusercontent.com/jdelon02/projectai/main/projectai.sh | bash -s --'" >> ~/.zshrc
source ~/.zshrc
```

**For Bash users:**
```bash
echo "alias projectai='curl -sSL https://raw.githubusercontent.com/jdelon02/projectai/main/projectai.sh | bash -s --'" >> ~/.bashrc
source ~/.bashrc
```

**For Fish shell users:**
```bash
echo "alias projectai='curl -sSL https://raw.githubusercontent.com/jdelon02/projectai/main/projectai.sh | bash -s --'" >> ~/.config/fish/config.fish
source ~/.config/fish/config.fish
```

### 🚀 Alternative Usage Options

**One-time use (no installation required):**
```bash
curl -sSL https://raw.githubusercontent.com/jdelon02/projectai/main/projectai.sh | bash -s -- <project_type> [additional_types...]
```

**Advanced shell function (for enhanced error handling):**
```bash
projectai() {
    if [ $# -eq 0 ]; then
        echo "Usage: projectai <primary_project_type> [additional_project_types...]"
        echo "Example: projectai drupal php mysql css javascript lando"
        return 1
    fi
    
    echo "🚀 Running ProjectAI with: $*"
    curl -sSL https://raw.githubusercontent.com/jdelon02/projectai/main/projectai.sh | bash -s -- "$@"
}
```

### ✅ Verify Installation
After installation, test it works:
```bash
projectai --help  # Should show usage information
```

**All installation methods run the script directly from GitHub - no local files needed!**

## Usage

### Basic Syntax
```bash
projectai <primary_project_type>[,additional_type1,additional_type2,...]
```

### Examples

**Single project type:**
```bash
projectai drupal
```

**Multiple project types (comma-separated):**
```bash
projectai drupal,php,mysql,css,javascript,lando
```

**Multiple project types (space-separated, legacy mode):**
```bash
projectai drupal php mysql css javascript lando
```

**Common project combinations:**
```bash
projectai react,typescript,tailwind  # React project
projectai python,fastapi,postgresql  # Python API project
projectai nodejs,express,mongodb     # Node.js backend
```

### Parameters

- **`primary_project_type`** (required): The main technology/framework for your project
- **`additional_project_types`** (optional): Supporting technologies, tools, or frameworks

**Note:** All project types must exist in your Agent OS installation (`~/.agent-os/`). If missing types are detected, the script will:
1. Show which types are missing
2. Provide the command to install them
3. Ask if you want to continue with available types only

## Interactive Setup

After running the command, you'll be prompted to select your AI coding tool:

```
🤖 Which AI coding tool are you using?

1) Claude Code (Anthropic's desktop app)
   - Uses CLAUDE.md files for instructions
   - Supports /plan-product, /create-spec, /execute-task commands

2) VS Code with GitHub Copilot
   - Uses .github/instructions/main.instructions.md files
   - Works with GitHub Copilot and other extensions

3) Cursor IDE
   - Uses .cursorrules files for configuration
   - Integrated AI-powered code editor
```

### IDE Support

When running ProjectAI, you'll choose your IDE:

1. **Claude Code (Anthropic)**
   - Creates: `CLAUDE.md`
   - Supports: Agent OS commands (`/plan-product`, `/create-spec`, etc.)
   - Templates: Fetched from `project_templates/claude-code/`

2. **VS Code with GitHub Copilot**
   - Creates: 
     - `.github/instructions/main.instructions.md`
     - `.github/copilot-instructions.md`
     - `.vscode/project-name.code-workspace`
   - Supports: Copilot Chat commands and auto-configuration
   - Templates: Fetched from `project_templates/.github/` and `.vscode/`

3. **Cursor IDE**
   - Creates: `.cursorrules`
   - Supports: Built-in AI features
   - Templates: Fetched from `project_templates/cursor-ide/`

### Generated Files

Each IDE setup includes:
- IDE-specific instruction files
- Project templates (from GitHub)
- Customized configurations
- Documentation

Directory structure after setup:
```
your-project/
├── .github/                    # For VS Code/Copilot
│   ├── instructions/
│   │   └── main.instructions.md
│   └── copilot-instructions.md
├── .vscode/                    # VS Code specific
│   ├── project.code-workspace
│   └── settings.json
├── CLAUDE.md                   # For Claude Code
├── .cursorrules               # For Cursor IDE
└── [template directories]/    # Additional project files
```

## Project Structure After Setup

```
your-project/
├── CLAUDE.md or .cursorrules or .github/instructions/
├── .vscode/ (if using VS Code)
│   ├── your-project.code-workspace
│   ├── settings.json
│   └── tasks.json
├── docs/
│   └── README.md
├── src/
└── [other template directories]/
```

## Template Customization

All template files support these placeholders:
- `<PROJECTTYPE>` - Your primary project type
- `<DIRECTORY_NAME>` - Your project directory name
- `<ADDITIONAL_TYPES>` - Space-separated additional project types
- `<ALL_TYPES>` - All project types combined

## Troubleshooting

### Agent OS Not Found
```
❌ Error: Agent OS not found at ~/.agent-os
```
**Solution:** Install Agent OS first:
```bash
curl -sSL https://raw.githubusercontent.com/jdelon02/agent-os/main/setup.sh | bash
```

### Missing Project Types
```
⚠️ Warning: The following project types are not installed in Agent OS:
    - some-type
```
**Solution:** Install missing types:
```bash
curl -sSL https://raw.githubusercontent.com/jdelon02/agent-os/main/setup.sh | bash -s -- --dirs "some-type,another-type"
```

### Network Connection Issues
```
❌ Error: Cannot connect to GitHub
```
**Solution:** Check your internet connection and try again.

### Permission Errors
**Solution:** Ensure you have write permissions in the current directory.

## Advanced Usage

### Running in a Specific Directory
```bash
cd /path/to/your/project
curl -sSL https://raw.githubusercontent.com/jdelon02/projectai/main/projectai.sh | bash -s -- drupal php
```

### Custom GitHub Repository
If you've forked this project, you can use your own repository:
```bash
# Edit the BASE_URL in the script
BASE_URL="https://raw.githubusercontent.com/YOUR_USERNAME/projectai/main"
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Adding New IDE Support

1. Create a handler file in `ide_specific/new-ide.sh`
2. Implement `create_new_ide_instruction_file()` function
3. Update the IDE selection prompt in `projectai.sh`
4. Add the new case to the switch statement

See `ide_specific/README.md` for detailed instructions.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Related Projects

- [Agent OS](https://github.com/jdelon02/agent-os) - Structured AI-assisted development methodology
- [Builder Methods](https://buildermethods.com/agent-os) - Learn more about Agent OS

## Support

- 📖 [Documentation](https://buildermethods.com/agent-os)
- 🐛 [Issues](https://github.com/jdelon02/projectai/issues)
- 💬 [Discussions](https://github.com/jdelon02/projectai/discussions)

---

*ProjectAI extends Agent OS with automated project initialization and IDE-specific AI tool configuration.*
