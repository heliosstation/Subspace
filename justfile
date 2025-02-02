# Justfile for Nix Flake automation on macOS (Helios Station)

# Define system variables
SYSTEM_TYPE := "aarch64-darwin"
FLAKE_SYSTEM := "darwinConfigurations." + SYSTEM_TYPE + ".system"

# ANSI color and formatting variables using Just syntax
BOLD   := "\u{1b}[1m"
GREEN  := "\u{1b}[32m"
YELLOW := "\u{1b}[33m"
RED    := "\u{1b}[31m"
NC     := "\u{1b}[0m"   # Reset formatting

# Set environment variable globally for all recipes
export NIXPKGS_ALLOW_UNFREE := "1"

# ------------------------------------------------------------------
# Recipe: build
#
# This recipe builds the specified flake system and then cleans up.
# Bold yellow is used to emphasize the messages, and bold green indicates
# a successful build.
# ------------------------------------------------------------------
build:
    @echo "{{BOLD}}{{YELLOW}}Starting build...{{NC}}"
    nix --extra-experimental-features "nix-command flakes" build .#{{FLAKE_SYSTEM}}
    @echo "{{BOLD}}{{YELLOW}}Cleaning up...{{NC}}"
    unlink ./result
    @echo "{{BOLD}}{{GREEN}}Build complete!{{NC}}"

# ------------------------------------------------------------------
# Recipe: build-switch
#
# This recipe builds the flake, switches to the new generation,
# cleans up, and then confirms completion.
# ------------------------------------------------------------------
build-switch:
    @echo "{{BOLD}}{{YELLOW}}Starting build...{{NC}}"
    nix --extra-experimental-features "nix-command flakes" build .#{{FLAKE_SYSTEM}}
    @echo "{{BOLD}}{{YELLOW}}Switching to new generation...{{NC}}"
    ./result/sw/bin/darwin-rebuild switch --flake .#{{SYSTEM_TYPE}}
    @echo "{{BOLD}}{{YELLOW}}Cleaning up...{{NC}}"
    unlink ./result
    @echo "{{BOLD}}{{GREEN}}Switch to new generation complete!{{NC}}"

# ------------------------------------------------------------------
# Recipe: rollback
#
# This recipe lists available generations, prompts the user for a
# generation number, and rolls back to that generation.
# Bold red is used for error messaging, while bold yellow guides the user,
# and bold green confirms a successful rollback.
#       
# ------------------------------------------------------------------
rollback:
    @echo "{{BOLD}}{{YELLOW}}Available generations:{{NC}}"
    /run/current-system/sw/bin/darwin-rebuild --list-generations
    @echo -n "{{BOLD}}{{YELLOW}}Enter the generation number for rollback: {{NC}}"
    @read -r GEN_NUM; \
    if [ -z "$$GEN_NUM" ]; then \
      echo "{{BOLD}}{{RED}}No generation number entered. Aborting rollback.{{NC}}"; \
      exit 1; \
    else \
      echo "{{BOLD}}{{YELLOW}}Rolling back to generation $GEN_NUM...{{NC}}"; \
      /run/current-system/sw/bin/darwin-rebuild switch --flake .#macos --switch-generation ${GEN_NUM}; \
      echo "{{BOLD}}{{GREEN}}Rollback to generation $GEN_NUM complete!{{NC}}"; \
    fi