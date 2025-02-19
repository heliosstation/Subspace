{
  description = "Subspace: Helios Station system configuration";

  outputs = inputs: import ./outputs inputs;

  # The nixConfig here only affects the flake itself, not the system configuration!
  # For more information, see:
  # https://nixos-and-flakes.thiscute.world/nix-store/add-binary-cache-servers
  nixConfig = {
    # Additional substituters for fetching packages
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    # Trusted public keys for the additional substituters
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    # NixOS package source, using unstable branch by default
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Additional NixOS package source, using unstable branch
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Additional NixOS package source, using stable branch
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";

    # Secret Management with age
    agenix.url = "github:ryantm/agenix";

    # Manager user configuration
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nixpkgs for Darwin (macOS)
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # Manage macOS configuration
    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    # NixOS hardware configurations
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Manage Homebrew installations declaratively
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };

    # Homebrew dependencies
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };

    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    homebrew-services = {
      url = "github:homebrew/homebrew-services";
      flake = false;
    };

    homebrew-nikitabobko = {
      url = "github:nikitabobko/homebrew-tap";
      flake = false;
    };

    # Helios Station secrets [private repository]
    subsecrets = {
      url = "git+ssh://git@github.com/heliosstation/Section31.git";
      flake = false;
    };

    # Subspace Nix User Repository
    nur-heliosstation.url = "git+ssh://git@github.com/heliosstation/SubspaceNUR";

    # Lanzaboote - NixOS boot manager
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Impermanence: Makes NixOS stateless by discarding changes on reboot
    impermanence.url = "github:nix-community/impermanence";

    # Nixos-generators: Generate outputs for different targets
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Disko: Declarative disk partitioning for NixOS
    disko = {
      url = "github:nix-community/disko/v1.9.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Haumea: Maps a directory of Nix files into an attribute set
    haumea = {
      url = "github:nix-community/haumea/v0.2.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nixpak: Sandboxing for Nix
    nixpak = {
      url = "github:nixpak/nixpak";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Pre-commit hooks to format Nix code before commit
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Ghostty is a fast, feature-rich, and cross-platform terminal emulator
    ghostty = {
      url = "github:ghostty-org/ghostty";
    };
  };
}
