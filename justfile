# Just is a command runner, and a Justfile is similar to a Makefile, but simpler.

# Use Nushell for shell commands.
# To use this Justfile, you need to enter a shell with Just and Nushell installed:
#
#   nix shell nixpkgs#just nixpkgs#nushell
set shell := ["nu", "-c"]

utils_nu := absolute_path("build-commands.nu")

############################################################################
#
#  Common commands (suitable for all machines)
#
############################################################################

# List all the just commands
default:
  @just --list

# Run evaluation tests
[group('nix')]
test:
  nix eval .#evalTests --show-trace --print-build-logs --verbose

# Update all the flake inputs
[group('nix')]
up:
  nix flake update

# Update a specific input
# Usage: just upkg nixpkgs
[group('nix')]
upkg input:
  nix flake update {{input}}

# List all generations of the system profile
[group('nix')]
history:
  nix profile history --profile /nix/var/nix/profiles/system

# Open a nix shell with the flake
[group('nix')]
repl:
  nix repl -f flake:nixpkgs

# Remove all generations older than 7 days
# On Darwin, you may need to switch to the root user to run this command
[group('nix')]
clean:
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 7d

# Garbage collect all unused nix store entries
[group('nix')]
gc:
  # Garbage collect all unused nix store entries (system-wide)
  sudo nix-collect-garbage --delete-older-than 7d
  # Garbage collect all unused nix store entries (for the user - home-manager)
  # https://github.com/NixOS/nix/issues/8508
  nix-collect-garbage --delete-older-than 7d

# Enter a shell session which has all the necessary tools for this flake (Linux)
[linux]
[group('nix')]
shell:
  nix shell nixpkgs#git nixpkgs#neovim

# Enter a shell session which has all the necessary tools for this flake (macOS)
[macos]
[group('nix')]
shell:
  nix shell nixpkgs#git nixpkgs#neovim

# Format the nix files in this repo
[group('nix')]
fmt:
  nix fmt

# Show all the auto gc roots in the nix store
[group('nix')]
gcroot:
  ls -al /nix/var/nix/gcroots/auto/

# Verify all the store entries
# Nix Store can contain corrupted entries if the nix store object has been modified unexpectedly.
# This command will verify all the store entries,
# and we need to fix the corrupted entries manually via `sudo nix store delete <store-path-1> <store-path-2> ...`
[group('nix')]
verify-store:
  nix store verify --all

# Repair Nix Store Objects
[group('nix')]
repair-store *paths:
  nix store repair {{paths}}

############################################################################
#
#  Darwin related commands, dhd is my MacBook Pro's hostname
#
############################################################################

# Rollback Darwin configuration
[macos]
[group('desktop')]
darwin-rollback:
  #!/usr/bin/env nu
  use {{utils_nu}} *;
  darwin-rollback

# Deploy to dhd (macOS host)
[macos]
[group('desktop')]
dhd mode="default":
  #!/usr/bin/env nu
  use {{utils_nu}} *;
  darwin-build "dhd" {{mode}};
  darwin-switch "dhd" {{mode}}

# Reset Launchpad to force it to reindex Applications
[macos]
[group('desktop')]
reset-launchpad:
  defaults write com.apple.dock ResetLaunchPad -bool true
  killall Dock
