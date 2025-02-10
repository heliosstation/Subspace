{
  pkgs,
  ghostty,
  ...
}:
###########################################################
#
# Ghostty Configuration
# Github: https://github.com/ghostty-org/ghostty
# Docs: https://ghostty.org/docs
#
###########################################################
{
  programs.ghostty = {
    enable = true;
    # pkgs.ghostty is currently broken on darwin as of 02/09
    # See: https://github.com/ghostty-org/ghostty/discussions/3800
    package = 
        if pkgs.stdenv.isDarwin
        then pkgs.emptyDirectory
        else pkgs.ghostty;
    enableBashIntegration = false;
    installBatSyntax = false;

    settings = {
      theme = "catppuccin-mocha";

      font-family = "FiraCode Nerd";
      font-size = 13;

      background-opacity = 0.93;
      # Only supported on macOS;
      background-blur-radius = 10;
      scrollback-limit = 20000;
    };
  };
}