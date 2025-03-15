{lib, ...}: {
  darwinSystem = import ./darwin-system.nix;
  nixosSystem = import ./nixos-system.nix;

  attrs = import ./attrs.nix {inherit lib;};

  # Use path relative to the root of the project
  relativeToRoot = lib.path.append ../.;
  scanPaths = path:
    builtins.map
    (f: (path + "/${f}"))
    (builtins.attrNames
      (lib.attrsets.filterAttrs
        (
          path: _type:
            (_type == "directory") # Include directories
            || (
              (path != "default.nix") # Ignore default.nix
              && (lib.strings.hasSuffix ".nix" path) # Include .nix files
            )
        )
        (builtins.readDir path)));
}
