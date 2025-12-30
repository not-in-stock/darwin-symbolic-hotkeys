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
  exposeAndSpaces.spaces.moveToPreviousSpace = {
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
    # Mission Control (Expose and Spaces)
    exposeAndSpaces = {
      allWindows = {
        enable = true;
        shortcut = "ctrl+up";
      };
      applicationWindows = {
        enable = true;
        shortcut = "ctrl+down";
      };
      
      # Spaces subgroup
      spaces = {
        moveToPreviousSpace = {
          enable = true;
          shortcut = "ctrl+left";
        };
        moveToNextSpace = {
          enable = true;
          shortcut = "ctrl+right";
        };
      };
    };
    
    # Window management (macOS 15+)
    windows = {
      halves = {
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

| Category | Description |
|----------|-------------|
| `dashboardAndDock` | Launchpad & Dock |
| `display` | Display brightness |
| `exposeAndSpaces` | Mission Control |
| `windows` | Window management (tiling) |
| `keyboardInput` | Keyboard navigation |
| `inputSources` | Input source switching |
| `screenshots` | Screenshot shortcuts |
| `presenterOverlay` | Presenter overlay |
| `services` | Services menu |
| `spotlight` | Spotlight search |
| `universalAccess` | Accessibility |
| `applicationShortcuts` | App shortcuts |

## Finding Shortcut Names

To see all available shortcuts, you can inspect the generated JSON:

```bash
cat /path/to/darwin-symbolic-hotkeys/data/symbolic-hotkeys.json | jq
```

Or use `nix repl`:

```bash
nix repl
:lf github:YOUR_USERNAME/darwin-symbolic-hotkeys
lib.aarch64-darwin.shortcutData.categories
```

## How It Works

1. **Data Source**: Shortcut definitions are extracted from macOS system files (`DefaultShortcutsTable.xml`)
2. **JSON Generation**: A Python script parses the XML and generates structured JSON
3. **Nix Options**: The module dynamically creates Nix options from the JSON data
4. **Shortcut Parsing**: Human-readable shortcut strings are converted to macOS parameters
5. **Configuration**: Enabled shortcuts are written to `com.apple.symbolichotkeys` preferences

## Updating for New macOS Versions

If Apple adds new shortcuts in a macOS update:

1. Copy the new XML:
   ```bash
   cp /System/Library/ExtensionKit/Extensions/KeyboardSettings.appex/Contents/Resources/en.lproj/DefaultShortcutsTable.xml data/
   ```

2. Regenerate the JSON:
   ```bash
   python3 scripts/parse-shortcuts.py
   ```

3. The new shortcuts will automatically be available as Nix options

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
