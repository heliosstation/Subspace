{
  pkgs,
  pkgs-unstable,
  ...
}: {
  programs.alacritty = {
    enable = true;
    package = pkgs-unstable.alacritty;
    # https://alacritty.org/config-alacritty.html
    settings = {
      general.import = [
        ./catppuccin-mocha.toml
      ];
    };
  };
}
