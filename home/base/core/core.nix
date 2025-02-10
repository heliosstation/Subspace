{
  pkgs,
  nur-heliosstation,
  ...
}: {
  home.packages = with pkgs; [
    tldr
    cowsay
    gnupg
    gnumake

    fzf
    fd
    (ripgrep.override {withPCRE2 = true;})
    sad
    yq-go
    just
    delta
    lazygit
    gping
    doggo
    duf
    du-dust
    gdu

    nix-output-monitor
    hydra-check
    nix-index
    nix-init
    nix-melt
    nix-tree

    ncdu
  ];

  programs = {
    eza = {
      enable = true;
      git = true;
      icons = "auto";
    };

    bat = {
      enable = true;
      config = {
        pager = "less -FR";
        theme = "catppuccin-mocha";
      };
      themes = {
        catppuccin-mocha = {
          src = nur-heliosstation.packages.${pkgs.system}.catppuccin-bat;
          file = "Catppuccin-mocha.tmTheme";
        };
      };
    };

    fzf = {
      enable = true;
      # Catppuccin-Mocha
      colors = {
        "bg+" = "#313244";
        "bg" = "#1e1e2e";
        "spinner" = "#f5e0dc";
        "hl" = "#f38ba8";
        "fg" = "#cdd6f4";
        "header" = "#f38ba8";
        "info" = "#cba6f7";
        "pointer" = "#f5e0dc";
        "marker" = "#f5e0dc";
        "fg+" = "#cdd6f4";
        "prompt" = "#cba6f7";
        "hl+" = "#f38ba8";
      };
    };

    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };

    atuin = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
  };
}
