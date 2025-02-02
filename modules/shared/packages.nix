{ pkgs }:

with pkgs; [
  # System Utilities
  coreutils
  bash-completion
  killall
  openssh

  # Performance Monitoring & Process Management
  btop
  htop

  # Development & Build Tools
  just

  # Security & Encryption
  age
  gnupg

  # Text Processing & Terminal Utilities
  bat
  jq
  tree

  # Networking Tools
  curl
  wget
  netcat

  # Editors & IDEs
  neovim

  # Scripting & Automation
  fd
  ripgrep
]
