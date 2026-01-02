{
  description = "Declarative macOS symbolic hotkeys management for nix-darwin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      # Supported systems for the module (darwin only)
      darwinSystems = [
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      # Systems that can build documentation (includes Linux for CI)
      docsSystems = darwinSystems ++ [
        "x86_64-linux"
        "aarch64-linux"
      ];

      # Helper to generate per-system outputs
      forAllSystems = nixpkgs.lib.genAttrs darwinSystems;
      forDocsSystems = nixpkgs.lib.genAttrs docsSystems;
    in
    {
      # The main darwin module
      darwinModules = {
        default = import ./default.nix;
        symbolic-hotkeys = import ./default.nix;
      };

      # Expose the library for advanced usage
      lib = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          shortcuts = import ./lib/shortcuts.nix { inherit (pkgs) lib; };
          keycodes = import ./lib/keycodes.nix { inherit (pkgs) lib; };
          shortcutData = builtins.fromJSON (builtins.readFile ./data/symbolic-hotkeys.json);
        }
      );

      # Overlay for exposing lib functions
      overlays.default = final: prev: {
        darwin-symbolic-hotkeys = {
          shortcuts = import ./lib/shortcuts.nix { lib = final.lib; };
          keycodes = import ./lib/keycodes.nix { lib = final.lib; };
          shortcutData = builtins.fromJSON (builtins.readFile ./data/symbolic-hotkeys.json);
        };
      };

      # Documentation packages (available on all systems including Linux for CI)
      packages = forDocsSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          docs = import ./doc {
            inherit pkgs;
            revision = self.rev or self.dirtyRev or "main";
          };
        in
        {
          docs = docs.htmlDocs;
          options-json = docs.optionsJSON;
        }
      );
    };
}
