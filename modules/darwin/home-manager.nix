{ config, pkgs, lib, home-manager, ... }:

let
  user = "helios";
in
{
  imports = [];

  # Define user account settings
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;  # Automatically fetch the latest stable branch of Homebrew's git repository.
      upgrade = true;     # Upgrade all outdated Homebrew formulae, casks, and Mac App Store apps.
      cleanup = "zap";    # Remove all formulae and related files not listed in the generated Brewfile.
    };

    # Mac App Store (MAS) Applications
    #
    # These apps are installed via the `mas` CLI, which requires them to be 
    # previously purchased or downloaded under your Apple ID. If an app is not in 
    # your purchase history, the Mac App Store will refuse to install it.
    #
    # To install `mas`:
    # $ nix shell nixpkgs#mas
    #
    # Finding App IDs:
    # $ mas search <app-name>
    #
    # Note: If you’ve added these apps to your Apple ID but never installed them 
    # on this system, you may see "Redownload Unavailable with This Apple ID." 
    # This can be safely ignored.
    #
    # More info: https://github.com/mas-cli/mas
    masApps = {
      "infuse" = 1136220934;
      "xcode" = 497799835;
      "appledeveloper" = 640199958;
    };

    # Brews: `brew install`
    brews = pkgs.callPackage ./brews.nix {};
    
    # Casks: `brew install --cask`
    casks = pkgs.callPackage ./casks.nix {};
  };

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;
    users.${user} = { pkgs, config, lib, ... }:{
      home = {
        enableNixpkgsReleaseCheck = false;
        packages = pkgs.callPackage ./packages.nix {};

        stateVersion = "24.11";
      };
      programs = {} // import ../shared/home-manager.nix { inherit config pkgs lib; };
    };
  };
}
