{
  pkgs,
  pkgs-unstable,
  nur-heliosstation,
  ...
}: {
  programs.yazi = {
    enable = true;
    package = pkgs-unstable.yazi;
    enableBashIntegration = true;
    settings = {
      manager = {
        show_hidden = true;
        sort_dir_first = true;
      };
    };
  };

  xdg.configFile."yazi/theme.toml".source = "${nur-heliosstation.packages.${pkgs.system}.catppuccin-yazi}/mocha.toml";
}
