{
  lib,
  inputs,
  darwin-modules,
  home-modules ? [],
  subvars,
  system,
  genSpecialArgs,
  specialArgs ? (genSpecialArgs system),
  ...
}: let
  inherit (inputs) nixpkgs-darwin home-manager nix-darwin nix-homebrew;
in
  nix-darwin.lib.darwinSystem {
    inherit system specialArgs;
    modules =
      darwin-modules
      ++ [
        ({lib, ...}: {
          nixpkgs.pkgs = import nixpkgs-darwin {inherit system;};
        })
      ]
      ++ [nix-homebrew.darwinModules.nix-homebrew]
      ++ [
        ({lib, ...}: {
          nix-homebrew.enable = true;
          nix-homebrew.user = subvars.username;
          nix-homebrew.autoMigrate = true;
          nix-homebrew.mutableTaps = false;

          nix-homebrew.taps = {
            "homebrew/homebrew-core" = inputs.homebrew-core;
            "homebrew/homebrew-cask" = inputs.homebrew-cask;
            "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
            "homebrew/homebrew-services" = inputs.homebrew-services;
          };
        })
      ]
      ++ (
        lib.optionals ((lib.lists.length home-modules) > 0)
        [
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "home-manager.backup";

            home-manager.extraSpecialArgs = specialArgs;
            home-manager.users."${subvars.username}".imports = home-modules;
          }
        ]
      );
  }
