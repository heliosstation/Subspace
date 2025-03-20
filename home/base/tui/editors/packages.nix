{
  pkgs,
  pkgs-unstable,
  ...
}: {
  nixpkgs.config = {
    programs.npm.npmrc = ''
      prefix = ''${HOME}/.npm-global
    '';
  };

  home.packages = with pkgs; (
    # -*- Data & Configuration Languages -*-#
    [
      #-- Nix
      nil
      # Lints and suggestions for the nix programming language
      statix
      # Find and remove unused code in .nix source files
      deadnix
      # Nix Code Formatter
      alejandra

      #-- Markdown
      # Markdown Language Server
      marksman
      # Markdown Previewer
      glow

      #-- Protocol buffer
      # Linting and Formatting
      buf
    ]
    ++
    #-*- General Purpose Languages -*-#
    [
      #-- C/C++
      cmake
      cmake-language-server
      gnumake
      checkmake
      gcc
      # C/C++ tools with clang-tools, the unwrapped version won't
      # add aliases like `cc` and `c++`, so that it won't conflict with gcc
      llvmPackages.clang-unwrapped
      lldb

      #-- Python
      # Python Language Server
      pyright
      (python312.withPackages (
        ps:
          with ps; [
            ruff
            black

            # Common Python libraries
            jupyter
            ipython
            pandas
            requests
            pyquery
            pyyaml
            boto3
          ]
      ))

      #-- Rust
      pkgs-unstable.rustc
      pkgs-unstable.rust-analyzer
      pkgs-unstable.cargo
      pkgs-unstable.rustfmt
      pkgs-unstable.clippy

      #-- Golang
      go
      gomodifytags
      # Generate error handling code
      iferr
      # Generate code from interfaces
      impl
      # Contains tools like: godoc, goimports, etc.
      gotools
      # Go Language Server
      gopls
      # Go Debugger
      delve

      #-- Zig
      zls

      #-- Lua
      stylua
      lua-language-server

      #-- Bash
      nodePackages.bash-language-server
      shellcheck
      shfmt
    ]
    #-*- Web Development -*-#
    ++ [
      nodePackages.nodejs
      nodePackages.typescript
      nodePackages.typescript-language-server
      # HTML/CSS/JSON/ESLint language servers extracted from vscode
      nodePackages.vscode-langservers-extracted
      nodePackages."@tailwindcss/language-server"
      emmet-ls
    ]
    ++ [
      # Code formatter
      nodePackages.prettier
      fzf
      # Disk Usage Analyzer
      gdu
      # Recursively searches directories for a regex pattern
      (ripgrep.override {withPCRE2 = true;})
    ]
  );
}
