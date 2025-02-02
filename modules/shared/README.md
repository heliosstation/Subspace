## Shared
A lot of the code powering macOS and NixOS actually lives here! 🛠️

This config is shared between both systems, covering essentials like git, zsh, vim, and tmux.

## Layout
```
.
├── 📁 config             # Non-Nix config files  
├── 🏗️ default.nix        # Defines how overlays are imported 
├── 🎯 home-manager.nix   # The core—most shared config lives here 
├── 📦 packages.nix       # Packages to be shared 

```
