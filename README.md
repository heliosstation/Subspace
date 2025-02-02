# Subspace: Nix Config for Helios Station

## Overview
Subspace is my personal Nix-based development environment, running seamlessly across multiple platforms. With Nix, I ensure a reproducible, declarative, and reliable software setup across all my devices.

This configuration powers my daily workflow on:

- 💻 MacBook Pro M1 – My primary workstation.
- 🖥️ Proxmox Servers (2x) – Hosting VMs and containers.
- ☁️ Virtual Machines & Containers – Running a mix of workloads across my homelab.

This setup allows me to maintain a consistent development environment, whether I'm working directly on my Mac, inside a VM, or managing my infrastructure.

If you're exploring Nix for your own multi-device setup, you might find this configuration useful too. 🚀

Check out the step-by-step commands below to get started!

## ✨ Features

- **🚀 Nix Flakes**: [No Nix channels](#why-nix-flakes) ─ just a clean and modern `flake.nix` setup.  
- **🖥️ Unified Homelab & Workstation**: Runs seamlessly across **macOS (Apple Silicon)**, **Proxmox servers**, and **VMs/containers**, ensuring a consistent development and management experience.  
- **💡 Effortless Bootstrap**: One-liner Nix commands to set up from scratch on both **MacBook Pro M1** and **Proxmox VMs**—no manual tweaking required.  
- **🔧 Fully Declarative macOS Setup**: Custom macOS configuration with **UI tweaks, dock settings, and essential macOS apps**, all managed with `nix-darwin` and `home-manager`.  
- **🛠️ Hands-free Homebrew Management**: Automatic Homebrew setup via `nix-homebrew`, eliminating manual updates and package drift.  
- **💾 Declarative Disk Management**: No more disk utility headaches—`disko` handles partitions and formatting declaratively.  
- **🔒 Secure Secrets Management**: **`agenix`** for managing SSH keys, PGP, Syncthing credentials, and other sensitive data safely across machines.  
- **🏡 Built-in Home Manager**: `home-manager` integration keeps user configurations synced without extra CLI steps.  
- **🖥️ Optimized NixOS & Proxmox Config**: Performance-tuned **NixOS** setup with clean aesthetics, window animations, and smooth usability on both **bare metal and VMs**.  
- **⚡ Nix Overlays**: [Drop-in overlays](https://github.com/dustinlyons/nixos-config/tree/main/overlays) for patching and custom tweaks—just place a file in the right directory, and it works instantly!  
- **📜 Simplicity & Readability**: Designed for clarity and maintainability—no fragmented configs, just structured and elegant organization.  

## 📁 Layout **  

```
.
├── hosts        # Host-specific configuration
├── modules      # macOS and nix-darwin, NixOS, and shared configuration
├── overlays     # Drop an overlay file in this dir, and it runs. So far, mainly patches.
```

### Development workflow
So, in general, the workflow for managing your environment will look like
- make changes to the configuration
- run `nix run .#build-switch`
- watch Nix, `nix-darwin`, `home-manager`, etc do their thing
- go about your way and benefit from a declarative environment
  
### Trying packages
For quickly trying a package without installing it, I usually run
```sh
nix shell nixpkgs#hello
```

where `hello` is the package name from [nixpkgs](https://search.nixos.org/packages).