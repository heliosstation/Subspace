{
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages = with pkgs; [];

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;

      enableZshIntegration = true;
      enableBashIntegration = true;
    };
  };
}
