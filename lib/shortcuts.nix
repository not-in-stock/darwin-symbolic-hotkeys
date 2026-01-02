# Shortcut parsing functions for darwin-symbolic-hotkeys
#
# This module provides functions to parse human-readable shortcut strings
# (like "ctrl+cmd+l") into macOS symbolic hotkey parameters.

{ lib }:

let
  keycodes = import ./keycodes.nix { inherit lib; };
  inherit (keycodes) keys modifiers;

  # Default key for unknown characters
  defaultKey = { ascii = 65535; keyCode = 0; };

  # Parser for strings like "ctrl+cmd+l" or "ctrl + cmd + l"
  parseShortcut =
    shortcutStr:
    let
      # Normalize string: lowercase, remove spaces
      normalized = lib.toLower (lib.replaceStrings [ " " ] [ "" ] shortcutStr);

      # Split by delimiters (+, -)
      parts = lib.splitString "+" (lib.replaceStrings [ "-" ] [ "+" ] normalized);

      # Last part is the key, rest are modifiers
      keyChar = lib.last parts;
      modParts = lib.init parts;

      # Calculate sum of modifiers
      modifierSum = lib.foldl (acc: mod: acc + (modifiers.${mod} or 0)) 0 modParts;

      # Get key entry with both ASCII and keyCode
      key = keys.${keyChar} or defaultKey;
    in
    [
      key.ascii
      key.keyCode
      modifierSum
    ];

in
{
  # Function to create an enabled shortcut from a string
  # Example: mkShortcutFromString "ctrl+cmd+l"
  # Returns: { enabled = true; value = { parameters = [...]; type = "standard"; }; }
  mkShortcutFromString = shortcutStr: {
    enabled = true;
    value = {
      parameters = parseShortcut shortcutStr;
      type = "standard";
    };
  };

  # Function to create an enabled shortcut with raw parameters
  # Example: mkShortcut [ 108 37 1310720 ]
  mkShortcut = parameters: {
    enabled = true;
    value = {
      inherit parameters;
      type = "standard";
    };
  };

  # Function to create a disabled shortcut
  mkDisabledShortcut = {
    enabled = false;
    value = {
      parameters = [ 65535 65535 0 ];
      type = "standard";
    };
  };

  # Function to create a shortcut from user config
  # cfg: { enabled = bool; shortcut = null or string; }
  # defaults: { key, modifier, charKey? }
  mkShortcutFromConfig =
    cfg: defaults:
    if !cfg.enable then
      {
        enabled = false;
        value = {
          parameters = [ 65535 65535 0 ];
          type = "standard";
        };
      }
    else if cfg.shortcut != null then
      {
        enabled = true;
        value = {
          parameters = parseShortcut cfg.shortcut;
          type = "standard";
        };
      }
    else
      {
        # Use defaults from JSON
        enabled = true;
        value = {
          parameters = [
            (defaults.charKey or (defaults.key or 65535))
            (defaults.key or 65535)
            (defaults.modifier or 0)
          ];
          type = "standard";
        };
      };

  # Export the parser for direct use
  inherit parseShortcut;

  # Export keycodes for reference
  inherit keycodes;
}
