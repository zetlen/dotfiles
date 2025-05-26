# Dotfiles with Chezmoi

A modern, cross-platform dotfiles management system using [Chezmoi](https://www.chezmoi.io/).

## Features

- **Cross-platform**: Works on macOS, Linux (Ubuntu, Debian, Arch, Fedora, etc.)
- **Safe**: Dry-run mode, conflict detection, easy rollback
- **Modern tools**: mise, starship, sheldon, gum, and more
- **Templated**: OS-specific configurations with Go templates
- **Automated**: One-command setup on new machines

## Quick Start

### New Machine Setup
```bash
# Install and apply dotfiles in one command
chezmoi init --apply https://github.com/yourusername/dotfiles.git
```

### Manual Installation
```bash
# Install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)"

# Initialize with this repository
chezmoi init https://github.com/yourusername/dotfiles.git

# See what would be applied (dry run)
chezmoi diff

# Apply the dotfiles
chezmoi apply
```

## What Gets Installed

### Package Managers
- **macOS**: Homebrew
- **Linux**: Native package managers (apt, pacman, dnf, etc.)

### Development Tools
- **Runtime Management**: mise (replaces asdf)
- **Languages**: Node.js (LTS), Python (latest), Ruby (latest)
- **Shell**: zsh with starship prompt and sheldon plugin manager
- **Editor**: vim with vim-plug
- **Modern CLI**: eza, fd, ripgrep, fzf, gum, and more

### System Configuration
- **macOS**: System preferences, Finder settings
- **Git**: Smart configuration with tool detection
- **Shell**: History, completions, modern keybindings

## Daily Usage

### Updating Dotfiles
```bash
# Pull latest changes and apply
chezmoi update

# See what changed
chezmoi diff

# Apply manually if needed
chezmoi apply
```

### Making Changes
```bash
# Edit a dotfile
chezmoi edit ~/.zshrc

# See what would change
chezmoi diff

# Apply changes
chezmoi apply

# Commit and push changes
chezmoi cd
git add .
git commit -m "Update zsh config"
git push
```

### Managing Files
```bash
# Add a new dotfile to chezmoi
chezmoi add ~/.vimrc

# Remove a file from chezmoi management
chezmoi forget ~/.old-config

# See status of all managed files
chezmoi status
```

## Configuration

The system is configured through `.chezmoidata.yaml`:

```yaml
# Package lists for different operating systems
packages:
  common: [git, curl, wget, ...]
  darwin: [homebrew-specific-packages]
  debian: [apt-specific-packages]

# Tool behavior
tools:
  mise:
    auto_install: true
  vim:
    auto_update_plugins: true

# macOS preferences
macos:
  preferences:
    show_hidden_files: true
    disable_press_and_hold: true
```

## File Structure

```
~/.local/share/chezmoi/          # Chezmoi source directory
├── .chezmoidata.yaml            # Configuration data
├── dot_zshrc.tmpl              # ~/.zshrc template
├── dot_gitconfig.tmpl          # ~/.gitconfig template
├── dot_config/                 # ~/.config/ directory
│   ├── mise/conf.d/            # mise tool configurations
│   └── sheldon/plugins.toml    # zsh plugin configuration
└── run_once_*.sh.tmpl          # Installation scripts
```

## Templates

Files ending in `.tmpl` are Go templates that can use:

- **OS detection**: `{{ .chezmoi.os }}` (darwin/linux)
- **Distribution**: `{{ .chezmoi.osRelease.id }}` (ubuntu/arch/fedora/etc.)
- **Configuration data**: `{{ .packages.common }}`, `{{ .tools.mise.auto_install }}`
- **Tool detection**: `{{ lookPath "delta" }}`
- **Command output**: `{{ output "whoami" }}`

## Troubleshooting

### See what chezmoi would do
```bash
chezmoi diff
chezmoi apply --dry-run
```

### Reset a file
```bash
chezmoi forget ~/.zshrc
chezmoi add ~/.zshrc
```

### Debug templates
```bash
chezmoi execute-template < dot_zshrc.tmpl
```

### Complete reset
```bash
chezmoi purge
# Then re-initialize
```

## Migration from Other Systems

If you're migrating from another dotfiles system:

1. **Backup** your current dotfiles
2. **Test** this system on a VM or secondary machine
3. **Gradually migrate** files using `chezmoi add`
4. **Customize** `.chezmoidata.yaml` for your preferences

## Requirements

- **Git** (for cloning and version control)
- **curl** (for installation scripts)
- **sudo access** (for package installation)

All other tools are installed automatically by the setup scripts.

## License

MIT License - feel free to use and modify for your own dotfiles!
