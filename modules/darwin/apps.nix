{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:
##########################################################################
#
#  Install all apps and packages here.
#
#  NOTE: Your can find all available options in:
#    https://daiderd.com/nix-darwin/manual/index.html
#
#  NOTE：To remove the uninstalled APPs icon from Launchpad:
#    1. `sudo nix store gc --debug` & `sudo nix-collect-garbage --delete-old`
#    2. click on the uninstalled APP's icon in Launchpad, it will show a question mark
#    3. if the app starts normally:
#        1. right click on the running app's icon in Dock, select "Options" -> "Show in Finder" and delete it
#    4. hold down the Option key, a `x` button will appear on the icon, click it to remove the icon
#
##########################################################################
{
  # Install packages from nix's official package repository.
  #
  # The packages installed here are available to all users, and are reproducible across machines, and are rollbackable.
  # But on macOS, it's less stable than homebrew.
  #
  # Related Discussion: https://discourse.nixos.org/t/darwin-again/29331
  environment.systemPackages = with pkgs; [
    neovim
    git
    gnugrep
    gnutar

    # Darwin only apps
    utm # Virtual machine
  ];

  # Create /etc/zshrc that loads the nix-darwin environment.
  # this is required if you want to use darwin's default shell - zsh
  programs.zsh.enable = true;
  environment.shells = [
    pkgs.zsh
  ];

  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
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
      "Infuse" = 1136220934;
      "XCode" = 497799835;
      "AppleDeveloper" = 640199958;
    };

    taps = [
      "homebrew/services"
    ];

    brews = [
      "wget"
      "curl"

      # https://github.com/rgcr/m-cli
      "m-cli" #  Swiss Army Knife for macOS

      "gnu-sed"
      "gnu-tar"
    ];

    casks = [
      "firefox"
      "google-chrome"
      "visual-studio-code"

      "raycast"
      "stats"
      "chatgpt"

      # Terminal Emulators
      # pkgs.ghostty is currently broken on darwin as of 02/09, hence we use a cask
      # See: https://github.com/ghostty-org/ghostty/discussions/3800
      "ghostty"
    ];
  };
}
