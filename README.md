# darwin-symbolic-hotkeys
A declarative Nix module for managing macOS symbolic hotkeys (keyboard shortcuts) with human-readable syntax.

Instead of this:
```nix
system. defaults.CustomUserPreferences = {
  "com.apple.symbolichotkeys".AppleSymbolicHotKeys = {
    "79" = {
      enabled = true;
      value.parameters = [ 123 4 262144 ];
    };
  };
};
```

Write this:
```
darwin.symbolicHotkeys.expose.moveToPreviousSpace = {
  enabled = true;
  shortcut = "ctrl+left";
};
```
## Flake setup
```nix
{
  description = "Declarative macOS symbolic hotkeys management for nix-darwin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }: {
    darwinModules.default = import ./default.nix;
    darwinModules.symbolic-hotkeys = import ./default.nix;

    # Для тестирования
    packages = nixpkgs.lib.genAttrs [ "x86_64-darwin" "aarch64-darwin" ] (system: {
      default = self.packages.${system}.test;
    });
  };
}
```
