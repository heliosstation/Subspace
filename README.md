<h1 align="center">:snowflake: Subspace: Nix Config for Helios Station :snowflake:</h1>

<p align="center">
  <img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/palette/macchiato.png" width="400" />
</p>

<p align="center">
    <a href="https://nixos.org/">
        <img src="https://img.shields.io/badge/NixOS-25.05-informational.svg?style=for-the-badge&logo=nixos&color=F2CDCD&logoColor=D9E0EE&labelColor=302D41"></a>
  </a>
</p>

## Overview

Subspace is my personal Nix-based development environment, running seamlessly across multiple
platforms. With Nix, I ensure a reproducible, declarative, and reliable software setup across all my
devices.

This configuration powers my daily workflow on:

- 💻 MacBook Pro M1 – My primary workstation.
- [TODO] 🖥️ Proxmox Servers (3x) – Hosting VMs and containers.
- [TODO] ☁️ Virtual Machines & Containers – Running a mix of workloads across my homelab.

This setup allows me to maintain a consistent development environment, whether I'm working directly
on my Mac, inside a VM, or managing my infrastructure.

If you're exploring Nix for your own multi-device setup, you might find this configuration useful
too. 🚀

Check out the step-by-step commands below to get started!

## ✨ Features

- **🚀 Nix Flakes**: [No Nix channels](#why-nix-flakes) ─ just a clean and modern `flake.nix` setup.
- **🖥️ Unified Homelab & Workstation**: Runs seamlessly across **macOS (Apple Silicon)**, **Proxmox
  servers**, and **VMs/containers**, ensuring a consistent development and management experience.
- **💡 Effortless Bootstrap**: One-liner Nix commands to set up from scratch on both **MacBook Pro
  M1** and **Proxmox VMs**—no manual tweaking required.
- **🔧 Fully Declarative macOS Setup**: Custom macOS configuration with **UI tweaks, dock settings,
  and essential macOS apps**, all managed with `nix-darwin` and `home-manager`.
- **💾 Declarative Disk Management**: No more disk utility headaches—`disko` handles partitions and
  formatting declaratively.
- **🔒 Secure Secrets Management**: **`agenix`** for managing SSH keys, PGP, Syncthing credentials,
  and other sensitive data safely across machines.
- **🏡 Built-in Home Manager**: `home-manager` integration keeps user configurations synced without
  extra CLI steps.
- **🖥️ Optimized NixOS & Proxmox Config**: Performance-tuned **NixOS** setup with clean aesthetics,
  window animations, and smooth usability on both **bare metal and VMs**.
- **⚡ Nix Overlays**:
  [Drop-in overlays](https://github.com/dustinlyons/nixos-config/tree/main/overlays) for patching
  and custom tweaks—just place a file in the right directory, and it works instantly!
- **📜 Simplicity & Readability**: Designed for clarity and maintainability—no fragmented configs,
  just structured and elegant organization.

## 📁 Layout

```
.
├── home         # Home Manager configurations for user environments
├── hosts        # Host-specific configuration for different machines
├── lib          # Shared library functions and utilities
├── modules      # macOS, nix-darwin, NixOS, and shared configuration modules
├── outputs      # Build outputs and derivations
├── overlays     # Custom Nix overlays for package modifications and patches
├── secrets      # Encrypted secrets managed by agenix
└── vars         # Variable definitions and configurations
```

### Development workflow

So, in general, the workflow for managing your environment will look like:

- Make changes to the configuration
- Run `just <host-name>`, e.g.: `just dhd`
- Watch Nix, `nix-darwin`, `home-manager`, etc do their thing
- Go about your way and benefit

### 🚀 Justfile Commands Available

Here are the available `just` commands to manage this environment efficiently:
- **📜 `default`**: Lists all the Just commands.
  - Example: `just`

- **🧪 `test`**: Runs evaluation tests.
  - Example: `just test`

- **⬆️ `up`**: Updates all the flake inputs.
  - Example: `just up`

- **📦 `upkg`**: Updates a specific input.
  - Example: `just upkg nixpkgs`

- **📜 `history`**: Lists all generations of the system profile.
  - Example: `just history`

- **🔄 `repl`**: Opens a Nix shell with the flake.
  - Example: `just repl`

- **🧹 `clean`**: Removes all generations older than 7 days.
  - Example: `just clean`

- **🗑️ `gc`**: Garbage collects all unused Nix store entries.
  - Example: `just gc`

- **💻 `shell`**: Enters a shell session with necessary tools for this flake.
  - Example: `just shell`

- **📝 `fmt`**: Formats the Nix files in this repo.
  - Example: `just fmt`

- **🔍 `gcroot`**: Shows all the auto GC roots in the Nix store.
  - Example: `just gcroot`

- **🔍 `verify-store`**: Verifies all the store entries.
  - Example: `just verify-store`

- **🔧 `repair-store`**: Repairs Nix store objects.
  - Example: `just repair-store /nix/store/...`

- **↩️ `darwin-rollback`**: Rolls back Darwin configuration.
  - Example: `just darwin-rollback`

- **🚀 `dhd`**: Deploys to dhd (macOS host) using `darwin-build` and `darwin-switch` from `utils.nu`.
  - Example: `just dhd`

- **♻️ `reset-launchpad`**: Resets Launchpad to force it to reindex Applications.
  - Example: `just reset-launchpad`

### Trying packages

For quickly trying a package without installing it, I usually run

```sh
nix shell nixpkgs#hello
```

where `hello` is the package name from [nixpkgs](https://search.nixos.org/packages).
