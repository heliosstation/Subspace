{
  pkgs,
  nur-heliosstation,
  ...
}: {
  # https://github.com/catppuccin/btop/blob/main/themes/catppuccin_mocha.theme
  xdg.configFile."btop/themes".source = "${nur-heliosstation.packages.${pkgs.system}.catppuccin-btop}/themes";

  # replacement of htop/nmon
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "catppuccin_mocha";
      theme_background = false; # make btop transparent
    };
  };
}
