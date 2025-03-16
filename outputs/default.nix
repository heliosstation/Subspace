{
  self,
  nixpkgs,
  pre-commit-hooks,
  ...
} @ inputs: let
  inherit (inputs.nixpkgs) lib;
  sublib = import ../lib {inherit lib;};
  subvars = import ../vars {inherit lib;};

  # Add custom lib, vars, nixpkgs instance, and all inputs to specialArgs,
  # so they can be used in all NixOS/home-manager/darwin modules.
  genSpecialArgs = system:
    inputs
    // {
      inherit sublib subvars;

      # Use unstable branch for some packages to get the latest updates.
      pkgs-unstable = import inputs.nixpkgs-unstable {
        # Refer to the `system` parameter from outer scope recursively.
        inherit system;
        # Allow installation of non-free software for Chrome.
        config.allowUnfree = true;
      };
      pkgs-stable = import inputs.nixpkgs-stable {
        inherit system;
        # Allow installation of non-free software for Chrome.
        config.allowUnfree = true;
      };
    };

  # Arguments for all the haumea modules in this folder.
  args = {inherit inputs lib sublib subvars genSpecialArgs;};

  nixosSystems = {
    x86_64-linux = import ./x86_64-linux (args // {system = "x86_64-linux";});
  };
  darwinSystems = {
    aarch64-darwin = import ./aarch64-darwin (args // {system = "aarch64-darwin";});
  };
  allSystems = darwinSystems;
  allSystemNames = builtins.attrNames allSystems;
  nixosSystemValues = builtins.attrValues nixosSystems;
  darwinSystemValues = builtins.attrValues darwinSystems;
  allSystemValues = darwinSystemValues ++ nixosSystemValues;

  # Helper function to generate a set of attributes for each system.
  forAllSystems = func: (nixpkgs.lib.genAttrs allSystemNames func);
in {
  # Add attribute sets into outputs, for debugging
  debugAttrs = {inherit nixosSystems darwinSystems allSystems allSystemNames;};

  # NixOS Hosts
  nixosConfigurations =
    lib.attrsets.mergeAttrsList (map (it: it.nixosConfigurations or {}) nixosSystemValues);
  
  # Colmena - remote deployment via SSH
  colmena =
    {
      meta =
        (
          let
            system = "x86_64-linux";
          in {
            # colmena's default nixpkgs & specialArgs
            nixpkgs = import nixpkgs {inherit system;};
            specialArgs = genSpecialArgs system;
          }
        )
        // {
          # per-node nixpkgs & specialArgs
          nodeNixpkgs = lib.attrsets.mergeAttrsList (map (it: it.colmenaMeta.nodeNixpkgs or {}) nixosSystemValues);
          nodeSpecialArgs = lib.attrsets.mergeAttrsList (map (it: it.colmenaMeta.nodeSpecialArgs or {}) nixosSystemValues);
        };
    }
    // lib.attrsets.mergeAttrsList (map (it: it.colmena or {}) nixosSystemValues);
    
  # macOS Hosts configurations.
  darwinConfigurations =
    lib.attrsets.mergeAttrsList (map (it: it.darwinConfigurations or {}) darwinSystemValues);

  # Packages for all systems.
  packages = forAllSystems (
    system: allSystems.${system}.packages or {}
  );

  # Evaluate tests for all NixOS & darwin systems.
  evalTests = lib.lists.all (it: it.evalTests == {}) allSystemValues;

  # Pre-commit checks for all systems.
  checks = forAllSystems (
    system: {
      # eval-tests per system
      eval-tests = allSystems.${system}.evalTests == {};
      
      pre-commit-check = pre-commit-hooks.lib.${system}.run {
        src = sublib.relativeToRoot ".";
        hooks = {
          # Formatter.
          alejandra.enable = true;
          typos = {
            enable = true;
            settings = {
              write = true;
              configPath = "./.typos.toml";
            };
          };
          prettier = {
            enable = true;
            settings = {
              write = true;
              configPath = "./.prettierrc.yaml";
            };
          };
        };
      };
    }
  );

  # Development shells for all systems.
  devShells = forAllSystems (
    system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      default = pkgs.mkShell {
        packages = with pkgs; [
          # Fix non-interactive bash errors.
          bashInteractive
          # Fix `cc` replaced by clang, which causes nvim-treesitter compilation error.
          gcc
          # Nix-related formatter.
          alejandra
          typos
          nodePackages.prettier
        ];
        name = "dots";
        shellHook = ''
          ${self.checks.${system}.pre-commit-check.shellHook}
        '';
      };
    }
  );

  # Formatter for the nix code in this flake.
  formatter = forAllSystems (
    system: nixpkgs.legacyPackages.${system}.alejandra
  );
}
