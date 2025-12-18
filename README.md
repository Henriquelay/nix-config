# nix-config

Personal NixOS and macOS configurations using Nix flakes and home-manager.

## Hosts

- **acad-router**: NixOS desktop (Linux) - Primary machine
- **work-mac**: macOS work computer (Apple Silicon) with nix-darwin
- **netbook**: NixOS server
- **booter**: Installation ISO

## Repository Structure

```
nix-config/
├── home/                          # Shared home-manager configurations
│   ├── profiles/                  # Reusable configuration profiles
│   │   ├── base.nix              # Core cross-platform setup
│   │   ├── shell.nix             # Shell configurations (fish, starship, zoxide, etc.)
│   │   └── development.nix       # Development tools (helix, git, vscode, etc.)
│   └── programs/                  # Cross-platform program configs
│       ├── fish.nix, git.nix, helix.nix, kitty.nix, vscode.nix, etc.
│
├── hosts/                         # Per-host configurations (each with independent flake)
│   ├── acad-router/              # NixOS desktop
│   │   ├── flake.nix
│   │   ├── configuration.nix
│   │   └── henriquelay/
│   │       ├── home.nix
│   │       ├── stylix.nix
│   │       ├── programs.nix      # Linux-specific programs
│   │       └── linux/            # Linux-specific configs
│   │           ├── wayland.nix
│   │           └── wm/           # Window managers (sway, hyprland)
│   │
│   ├── work-mac/                 # macOS with nix-darwin
│   │   ├── flake.nix
│   │   ├── darwin-configuration.nix
│   │   └── henriquelay/
│   │       ├── home.nix
│   │       └── darwin/           # macOS-specific configs
│   │           └── macos.nix
│   │
│   ├── netbook/                  # NixOS server
│   └── booter/                   # Installation ISO
│
├── packages/                      # Custom Nix packages
└── devshell/                      # Development environment flakes
```

## Usage

### NixOS (acad-router)

```bash
cd ~/nix-config/hosts/acad-router
sudo nixos-rebuild switch --flake .
```

### macOS (work-mac)

```bash
cd ~/nix-config/hosts/work-mac
darwin-rebuild switch --flake .
```

**Note**: On macOS, you'll need to install nix-darwin first. See the [nix-darwin installation guide](https://github.com/LnL7/nix-darwin#installation).

## Cross-Platform Programs

Programs configured to work on both Linux and macOS:

### Shell & Terminal
- **fish** - Shell with plugins (autopair, colored-man-pages, done, grc, gruvbox, sponge)
- **starship** - Prompt
- **zoxide** - Smart cd replacement
- **fzf** - Fuzzy finder
- **kitty** - Terminal emulator

### Editors & Development
- **helix** - Primary editor with LSP configs
- **vscode** - Visual Studio Code
- **git** - With signing, aliases, and delta diff viewer
- **gh** - GitHub CLI
- **lazygit** - Git UI
- **gh-dash** - GitHub dashboard TUI

### Utilities
- **bat** - Better cat
- **ripgrep** - Fast grep
- **jq** - JSON processor
- **fd** - Fast find
- **eza** - Modern ls with icons
- **yazi** - File manager with archive preview
- **rclone** - Cloud sync
- **bottom** - System monitor
- **bacon** - Rust test runner

### AI Tools
- **aider-chat** - AI pair programming
- **claude-code** - Claude CLI

## Platform-Specific Features

### Linux (acad-router)
- **Window Managers**: sway (primary), hyprland
- **Wayland**: Full Wayland support with environment variables
- **GTK**: Gruvbox theme
- **Desktop Apps**: telegram, youtube-music, obsidian, obs-studio, etc.
- **Stylix**: Unified theming across applications
- **System Services**: syncthing, dunst, nextcloud-client

### macOS (work-mac)
- **nix-darwin**: System-level macOS configuration
- **System Settings**: Dock autohide, Finder settings, keyboard repeat rates
- **Native Theming**: Uses macOS native look and feel

## Design Philosophy

### Distributed Flake Architecture
Each host has its own independent flake.nix, making configurations self-contained and easy to build independently.

### Maximum Code Reuse
Cross-platform programs are configured once in `home/profiles/` and `home/programs/`, then imported by both Linux and macOS hosts.

### Clear Platform Separation
Platform-specific configurations are kept in separate directories:
- Linux-specific: `hosts/acad-router/henriquelay/linux/`
- macOS-specific: `hosts/work-mac/henriquelay/darwin/`

### Override Pattern
Shared configurations provide sensible defaults that can be overridden per-host using `lib.mkForce` (e.g., kitty font size: 20pt on Linux, 14pt on macOS).

## Adding a New Host

1. Create a new directory: `hosts/new-host/`
2. Create `flake.nix` with appropriate inputs (nixosConfiguration or darwinConfiguration)
3. Create host-specific configuration files
4. Create `henriquelay/home.nix` importing shared profiles:
   ```nix
   imports = [
     ../../../home/profiles/base.nix
     ../../../home/profiles/shell.nix
     ../../../home/profiles/development.nix
     # Add platform-specific imports
   ];
   ```
5. Add platform-specific configs in `linux/` or `darwin/` subdirectory

## Notes

- All helix configurations use the helix flake input for bleeding-edge features
- Shared modules are imported via relative paths (e.g., `../../../home/profiles/base.nix`)
- Git-tracked files only: When using flakes, only files tracked by git are included in builds
- Font configurations differ per platform for optimal readability
- The `customXkbConfig` parameter in acad-router is host-specific and not shared

## Troubleshooting

### Build fails with "path does not exist"
Make sure all new files are tracked by git: `git add <file>`

### Home-manager option renamed warnings
Update option names to their new equivalents (e.g., `pinentryPackage` → `pinentry.package`)

### Program not available on macOS
Check if the package exists in nixpkgs for darwin. Use conditional logic if needed:
```nix
home.packages = with pkgs; [
  cross-platform-package
] ++ lib.optionals pkgs.stdenv.isLinux [
  linux-only-package
];
```
