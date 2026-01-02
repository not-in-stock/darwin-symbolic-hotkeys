# darwin-symbolic-hotkeys
#
# A declarative Nix module for managing macOS symbolic hotkeys
# with human-readable syntax.
#
# Example usage:
#   darwin.symbolicHotkeys = {
#     exposeAndSpaces.spaces.moveToPreviousSpace = {
#       enable = true;
#       shortcut = "ctrl+left";
#     };
#   };

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.darwin.symbolicHotkeys;

  # Load the generated shortcut data
  shortcutData = builtins.fromJSON (builtins.readFile ./data/symbolic-hotkeys.json);

  # Load the shortcuts library
  shortcuts = import ./lib/shortcuts.nix { inherit lib; };

  # Type for a single shortcut configuration
  shortcutSubmodule =
    { name, ... }:
    {
      options = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether to configure this shortcut.";
        };

        shortcut = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "ctrl+cmd+l";
          description = ''
            The keyboard shortcut string.
            Format: "modifier1+modifier2+key"

            Modifiers: ctrl, cmd, opt/alt, shift, fn/globe
            Keys: a-z, 0-9, f1-f12, left, right, up, down, space, return, etc.

            If null, uses the system default shortcut.
          '';
        };
      };
    };

  # Generate options for a single shortcut
  mkShortcutOption =
    shortcutInfo:
    lib.mkOption {
      type = lib.types.submodule shortcutSubmodule;
      default = { };
      description = "${shortcutInfo.name} (ID: ${toString shortcutInfo.id})";
    };

  # Generate options for a group of shortcuts (including subgroups)
  mkGroupOptions =
    groupData:
    let
      shortcutOpts = lib.mapAttrs (name: info: mkShortcutOption info) (groupData.shortcuts or { });

      # Handle subgroups recursively
      subgroupOpts = lib.mapAttrs (
        name: subgroup:
        lib.mkOption {
          type = lib.types.submodule {
            options = lib.mapAttrs (sname: sinfo: mkShortcutOption sinfo) (subgroup.shortcuts or { });
          };
          default = { };
          description = subgroup.name or name;
        }
      ) (groupData.subgroups or { });
    in
    shortcutOpts // subgroupOpts;

  # Generate options for a category
  mkCategoryOption =
    categoryData:
    lib.mkOption {
      type = lib.types.submodule {
        options = mkGroupOptions categoryData;
      };
      default = { };
      description = categoryData.name;
    };

  # Generate all category options
  allCategoryOptions = lib.mapAttrs (
    name: categoryData: mkCategoryOption categoryData
  ) shortcutData.categories;

  # Convert a shortcut config to AppleSymbolicHotKeys format
  shortcutToHotkey =
    shortcutInfo: shortcutCfg:
    {
      name = toString shortcutInfo.id;
      value = shortcuts.mkShortcutFromConfig shortcutCfg {
        key = shortcutInfo.defaultKey or 65535;
        modifier = shortcutInfo.defaultModifier or 0;
        charKey = shortcutInfo.defaultCharKey or null;
      };
    };

  # Collect all enabled shortcuts from a category config
  collectCategoryHotkeys =
    categoryName: categoryData: categoryCfg:
    let
      # Direct shortcuts in category
      directHotkeys = lib.filterAttrs (n: v: v != null) (
        lib.mapAttrs (
          shortcutName: shortcutCfg:
          let
            shortcutInfo = categoryData.shortcuts.${shortcutName} or null;
          in
          if shortcutInfo != null then shortcutToHotkey shortcutInfo shortcutCfg else null
        ) (lib.filterAttrs (n: v: (categoryData.shortcuts or {}) ? ${n}) categoryCfg)
      );

      # Shortcuts in subgroups
      subgroupHotkeys = lib.flatten (
        lib.mapAttrsToList (
          subgroupName: subgroupData:
          let
            subgroupCfg = categoryCfg.${subgroupName} or { };
          in
          lib.mapAttrsToList (
            shortcutName: shortcutCfg:
            let
              shortcutInfo = subgroupData.shortcuts.${shortcutName} or null;
            in
            if shortcutInfo != null then shortcutToHotkey shortcutInfo shortcutCfg else null
          ) subgroupCfg
        ) (categoryData.subgroups or { })
      );
    in
    (lib.attrValues directHotkeys) ++ (lib.filter (x: x != null) subgroupHotkeys);

  # Collect all enabled hotkeys from all categories
  allHotkeys = lib.flatten (
    lib.mapAttrsToList (
      categoryName: categoryCfg:
      let
        categoryData = shortcutData.categories.${categoryName} or null;
      in
      if categoryData != null then collectCategoryHotkeys categoryName categoryData categoryCfg else [ ]
    ) cfg
  );

  # Convert list of {name, value} to attribute set
  hotkeyAttrs = lib.listToAttrs (lib.filter (x: x != null) allHotkeys);

in
{
  options.darwin.symbolicHotkeys = allCategoryOptions;

  config = lib.mkIf (hotkeyAttrs != { }) {
    system.defaults.CustomUserPreferences = {
      "com.apple.symbolichotkeys" = {
        AppleSymbolicHotKeys = hotkeyAttrs;
      };
    };
  };
}
