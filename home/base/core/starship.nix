{
  pkgs,
  nur-heliosstation,
  ...
}: {
  programs.starship = {
    enable = true;

    enableBashIntegration = true;
    enableZshIntegration = true;

    settings =
      {
        character = {
          success_symbol = "[›](bold green)";
          error_symbol = "[›](bold red)";
        };

        palette = "catppuccin_mocha";
      }
      // builtins.fromTOML (builtins.readFile "${nur-heliosstation.packages.${pkgs.system}.catppuccin-starship}/palettes/mocha.toml");
  };
}
