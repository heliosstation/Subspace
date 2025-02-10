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
let
  # pkgs.ghostty is currently broken on darwin as of 02/09
  # See: https://github.com/ghostty-org/ghostty/discussions/3800
  # https://github.com/nix-community/home-manager/issues/6295
  ghosttyPkg =
    if pkgs.stdenv.isDarwin then
      (pkgs.writeShellScriptBin "gostty-mock" "true")
    else
      ghostty.packages.${pkgs.system}.default;
in
{
  programs.ghostty = {
    enable = true;
    package = ghosttyPkg;
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

      # https://ghostty.org/docs/config/reference#command
      #  To resolve issues:
      #    1. https://github.com/ryan4yin/nix-config/issues/26
      #    2. https://github.com/ryan4yin/nix-config/issues/8
      #  Spawn a nushell in login mode via `bash`
      command = "${pkgs.bash}/bin/bash --login -c 'nu --login --interactive'";
    };
  };
}