{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:
###############################################################################
#
#  Neovim configuration
#
#e#############################################################################
let
  configPath = "${config.home.homeDirectory}/Projects/Subspace/home/base/tui/editors/neovim/nvim";
in {
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink configPath;

  programs = {
    neovim = {
      enable = true;
      package = pkgs-unstable.neovim-unwrapped;

      viAlias = true;
      vimAlias = true;
    };
  };
}
