# darwin-symbolic-hotkeys

A declarative Nix module for managing macOS symbolic hotkeys (keyboard shortcuts) with human-readable syntax.

## Overview

macOS system keyboard shortcuts are configured through "symbolic hotkeys" - a complex system using numeric IDs and bitmask values. This module provides a declarative, human-readable interface for managing these shortcuts in your nix-darwin configuration.

**Instead of this:**

```nix
system.defaults.CustomUserPreferences = {
  "com.apple.symbolichotkeys".AppleSymbolicHotKeys = {
    "79" = {
      enabled = true;
      value.parameters = [ 123 4 262144 ];
      value.type = "standard";
    };
  };
};
```

**Write this:**

```nix
darwin.symbolicHotkeys = {
  missionControl.missionControlGroup.moveLeftASpace = {
    enable = true;
  shortcut = "ctrl+left";
  };
};
```

## Installation

### Using Flakes (recommended)

Add to your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    darwin.url = "github:LnL7/nix-darwin";
    darwin-symbolic-hotkeys.url = "github:YOUR_USERNAME/darwin-symbolic-hotkeys";
  };

  outputs = { self, nixpkgs, darwin, darwin-symbolic-hotkeys, ... }: {
    darwinConfigurations.your-hostname = darwin.lib.darwinSystem {
      system = "aarch64-darwin";  # or "x86_64-darwin"
      modules = [
        darwin-symbolic-hotkeys.darwinModules.default
        ./configuration.nix
      ];
    };
  };
}
```

## Usage

### Basic Example

```nix
{ config, ... }:

{
  darwin.symbolicHotkeys = {
    # Mission Control
    missionControl = {
      missionControl = {
        enable = true;
        shortcut = "ctrl+up";
      };
      applicationWindows = {
        enable = true;
        shortcut = "ctrl+down";
      };

      # Mission Control subgroup (spaces navigation)
      missionControlGroup = {
        moveLeftASpace = {
          enable = true;
          shortcut = "ctrl+left";
        };
        moveRightASpace = {
          enable = true;
          shortcut = "ctrl+right";
        };

        # Switch to specific desktops (dynamically created by macOS)
        switchToDesktop1 = {
          enable = true;
          shortcut = "ctrl+1";
        };
        switchToDesktop2 = {
          enable = true;
          shortcut = "ctrl+2";
        };
        # ... up to switchToDesktop16
      };
    };

    # Window management (macOS 15+)
    windows = {
      halvesGroup = {
        tileLeftHalf = {
          enable = true;
          shortcut = "fn+ctrl+opt+cmd+left";
        };
        tileRightHalf = {
          enable = true;
          shortcut = "fn+ctrl+opt+cmd+right";
        };
      };
    };

    # Screenshots
    screenshots = {
      savePictureOfScreenAsAFile = {
        enable = true;
        shortcut = "shift+cmd+3";
      };
      savePictureOfSelectedAreaAsAFile = {
        enable = true;
        shortcut = "shift+cmd+4";
      };
    };

    # Spotlight
    spotlight = {
      showSpotlightSearch = {
        enable = true;
        shortcut = "cmd+space";
      };
    };
  };
}
```

### Shortcut String Format

Shortcuts are specified as strings with modifiers and a key, separated by `+` or `-`:

```
modifier1+modifier2+key
```

**Modifiers:**
- `ctrl` / `control` - Control key
- `cmd` / `command` - Command key
- `opt` / `option` / `alt` - Option key
- `shift` - Shift key
- `fn` / `globe` - Function/Globe key

**Keys:**
- Letters: `a` through `z`
- Numbers: `0` through `9`
- Function keys: `f1` through `f20`
- Arrows: `left`, `right`, `up`, `down`
- Special: `space`, `return`, `tab`, `escape`, `delete`
- Punctuation: `comma`, `period`, `slash`, `semicolon`, etc.

**Examples:**
- `ctrl+left` - Control + Left Arrow
- `cmd+space` - Command + Space
- `shift+cmd+3` - Shift + Command + 3
- `fn+ctrl+opt+cmd+left` - Fn + Control + Option + Command + Left

## Available Categories

The module provides options for the following categories:

| Category | macOS Settings Name | Subgroups |
|----------|---------------------|-----------|
| `launchpadDock` | Launchpad & Dock | - |
| `display` | Display | - |
| `missionControl` | Mission Control | `missionControlGroup` |
| `windows` | Windows | `generalGroup`, `halvesGroup`, `quartersGroup`, `arrangeGroup`, `fullScreenTileGroup` |
| `keyboard` | Keyboard | - |
| `inputSources` | Input Sources | - |
| `screenshots` | Screenshots | - |
| `presenterOverlay` | Presenter Overlay | - |
| `services` | Services | - |
| `spotlight` | Spotlight | - |
| `accessibility` | Accessibility | `contrastGroup`, `liveCaptionsGroup`, `liveSpeechGroup`, `zoomGroup` |
| `appShortcuts` | App Shortcuts | `allApplicationsGroup` |

## Finding Shortcut Names

### Option 1: View the shortcuts tree

Generate a human-readable tree of all available shortcuts:

```bash
# Plain text format
python3 scripts/generate-tree.py

# Markdown format (save to file)
python3 scripts/generate-tree.py --format markdown --output SHORTCUTS_TREE.md

# Without IDs or dynamic markers
python3 scripts/generate-tree.py --no-ids --no-dynamic
```

### Option 2: Inspect the JSON directly

```bash
cat /path/to/darwin-symbolic-hotkeys/data/symbolic-hotkeys.json | jq
```

### Option 3: Use nix repl

```bash
nix repl
:lf github:YOUR_USERNAME/darwin-symbolic-hotkeys
lib.aarch64-darwin.shortcutData.categories
```

## Dynamic Shortcuts

Some shortcuts are dynamically created by macOS and don't appear in system configuration files. These include:

### Desktop Switching (IDs 118-133)

These shortcuts allow switching to specific Mission Control desktops:

- **Desktop 1-10** (IDs 118-127): Use `Ctrl+1` through `Ctrl+0`
- **Desktop 11-16** (IDs 128-133): Use `Shift+Ctrl+1` through `Shift+Ctrl+6`

Example configuration:

```nix
darwin.symbolicHotkeys.missionControl.missionControlGroup = {
  switchToDesktop1.enable = true;  # Ctrl+1
  switchToDesktop2.enable = true;  # Ctrl+2
  switchToDesktop11.enable = true; # Shift+Ctrl+1
};
```

**Note**: These shortcuts are included in the module based on empirical evidence from the macOS system. They only become active in macOS when you have created the corresponding number of Mission Control spaces.

## How It Works

1. **Data Source**: Shortcut definitions are extracted from macOS system files:
   - `DefaultShortcutsTable.xml` - shortcut IDs, key codes, and modifiers
   - `DefaultShortcutsTable.loctable` - localized display names
2. **JSON Generation**: A Python script parses the XML and applies localization to generate structured JSON
3. **Dynamic Shortcuts**: Desktop switching shortcuts (IDs 118-133) are added programmatically as they don't exist in system files but are dynamically created by macOS
4. **Nix Options**: The module dynamically creates Nix options from the JSON data
5. **Shortcut Parsing**: Human-readable shortcut strings are converted to macOS parameters
6. **Configuration**: Enabled shortcuts are written to `com.apple.symbolichotkeys` preferences

The option names use localized names from macOS System Settings for better discoverability.

## Updating for New macOS Versions

If Apple adds new shortcuts in a macOS update, you can update the data using the provided script:

```bash
./scripts/update-data.sh
```

This will:
1. Copy the new `DefaultShortcutsTable.xml` from the system
2. Extract updated localization from `DefaultShortcutsTable.loctable`
3. Regenerate `symbolic-hotkeys.json` with localized names

Alternatively, you can update manually:

```bash
# Copy XML
cp /System/Library/ExtensionKit/Extensions/KeyboardSettings.appex/Contents/Resources/en.lproj/DefaultShortcutsTable.xml data/

# Extract localization
plutil -convert json -o - /System/Library/ExtensionKit/Extensions/KeyboardSettings.appex/Contents/Resources/DefaultShortcutsTable.loctable | jq '.en' > data/localization.json

# Regenerate JSON
python3 scripts/parse-shortcuts.py
```

The new shortcuts will automatically be available as Nix options with proper localized names.

## Advanced Usage

### Using the Library Directly

You can access the shortcut parsing functions directly:


```nix
{ pkgs, ... }:

let
  shortcuts = pkgs.darwin-symbolic-hotkeys.shortcuts;
in
{
  # Create a shortcut from string
  myShortcut = shortcuts.mkShortcutFromString "ctrl+cmd+l";

  # Create with raw parameters
  rawShortcut = shortcuts.mkShortcut [ 108 37 1310720 ];

  # Create a disabled shortcut
  disabled = shortcuts.mkDisabledShortcut;
}
```

### Accessing Key Codes

```nix
let
  keycodes = pkgs.darwin-symbolic-hotkeys.keycodes;
in
{
  # Key code for 'L'
  lKeyCode = keycodes.keyCodes.l;  # 37

  # Modifier for Command
  cmdMod = keycodes.modifiers.cmd;  # 1048576
}
```

## Troubleshooting

### Changes Not Taking Effect

After applying your configuration, you may need to:
1. Log out and back in, or
2. Run: `killall cfprefsd`

### Finding the Symbolic Hotkey ID

If you need to find the ID for a specific shortcut:

```bash
defaults read com.apple.symbolichotkeys AppleSymbolicHotKeys
```

## Contributing

Contributions are welcome! Please ensure:
1. The Python parser handles new XML structures
2. New shortcuts are properly categorized
3. Documentation is updated

## License

MIT License

## Credits

- Built for use with [nix-darwin](https://github.com/LnL7/nix-darwin)
- Inspired by the need for declarative macOS configuration
