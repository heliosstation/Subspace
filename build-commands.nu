# ================= macOS related =========================

# This function builds the specified Darwin configuration.
# It can operate in two modes: normal and debug.
# In debug mode, it shows detailed output via nix-output-monitor.
#
# Parameters:
#   - name: The name of the Darwin configuration.
#   - mode: The mode of operation ("debug" or normal).
export def darwin-build [
    name: string
    mode: string
] {
    let target = $".#darwinConfigurations.($name).system"
    if "debug" == $mode {
        nom build $target --extra-experimental-features "nix-command flakes"  --show-trace --verbose
    } else {
        nix build $target --extra-experimental-features "nix-command flakes"
    }
}

# This function switches the Darwin configuration to the specified one.
# It can operate in two modes: normal and debug.
# In debug mode, it shows detailed output.
#
# Parameters:
#   - name: The name of the Darwin configuration.
#   - mode: The mode of operation ("debug" or normal).
export def darwin-switch [
    name: string
    mode: string
] {
    if "debug" == $mode {
        ./result/sw/bin/darwin-rebuild switch --flake $".#($name)" --show-trace --verbose
    } else {
        ./result/sw/bin/darwin-rebuild switch --flake $".#($name)"
    }
}

# This function performs a rollback of the Darwin system configuration.
# It executes the `darwin-rebuild` command with the `--rollback` option
# to revert to the previous system state.
#
# Usage:
#   darwin-rollback
export def darwin-rollback [] {
    ./result/sw/bin/darwin-rebuild --rollback
}

# ================= NixOS related =========================

# This function builds the specified NixOS configuration.
# It can operate in two modes: normal and debug.
# In debug mode, it shows detailed output via nix-output-monitor.
#
# Parameters:
#   - name: The name of the NixOS configuration.
#   - mode: The mode of operation ("debug" or normal).
export def nixos-switch [
    name: string
    mode: string
] {
    if "debug" == $mode {
        # show details via nix-output-monitor
        nom build $".#nixosConfigurations.($name).config.system.build.toplevel" --show-trace --verbose
        nixos-rebuild switch --use-remote-sudo --flake $".#($name)" --show-trace --verbose
    } else {
        nixos-rebuild switch --use-remote-sudo --flake $".#($name)"
    }
}

# ==================== Virtual Machines related =====================

# Build and upload a VM image
export def upload-vm [
    name: string
    mode: string
] {
    let target = $".#($name)"
    if "debug" == $mode {
        nom build $target --show-trace --verbose
    } else {
        nix build $target
    }

    let remote = $"ryan@rakushun:/data/caddy/fileserver/vms/kubevirt-($name).qcow2"
    rsync -avz --progress --copy-links --checksum result $remote
}