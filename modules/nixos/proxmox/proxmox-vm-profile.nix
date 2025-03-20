{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.proxmox-vm-profile;
in {
  # The import is necessary when the VM profile is used in a non-packaging context.
  imports = [./proxmox-image.nix];

  options.proxmox-vm-profile = {
    template = mkOption {
      type = types.enum [
        "proxmox-legacy"
        "proxmox-standard"
        "proxmox-k3s-server"
        "proxmox-k3s-agent"
      ];
      description = mdDoc ''
        Which Proxmox VM template to use.

        Available options:
        - proxmox-legacy: i440fx-based VM with VirtIO storage (Higher Compatibility)
        - proxmox-standard: q35-based VM with optimized SCSI storage (Recommended)
        - proxmox-k3s-server: q35-based VM optimized for K3s server node (K3s)
        - proxmox-k3s-agent: q35-based VM optimized for K3s agent node (K3s)
      '';
      example = "proxmox-standard";
      default = "proxmox-standard";
    };
  };

  config = let
    isStandard = cfg.template == "proxmox-standard";
    isK3sServer = cfg.template == "proxmox-k3s-server";
    isK3sAgent = cfg.template == "proxmox-k3s-agent";

    isOptimized = cfg.template == isStandard || isK3sServer || isK3sAgent;

    diskSize =
      if isK3sAgent
      then 32768
      else if isK3sServer
      then 20480
      else 10240;
    cores =
      if isK3sAgent
      then 8
      else 2;
    memory =
      if isK3sAgent
      then (24 * 1024)
      else if isK3sServer
      then (4 * 1024)
      else (2 * 1024);
  in {
    virtualisation.diskSize = mkDefault diskSize;

    proxmox = {
      diskType =
        if isOptimized
        then "scsi"
        else "virtio";

      kernelModules = {
        extraModules =
          []
          ++ optionals isOptimized [
            "vfio-pci"
            "virtio_scsi"
            "scsi_mod"
            "sd_mod"
            "ata_piix"
            "ahci"
            "uas"
            "usb_storage"
            "usbcore"
            "ehci_pci"
            "xhci_pci"
            "ext4"
          ];
        extraInitrdModules =
          []
          ++ optionals isOptimized [
            "virtio_scsi"
            "virtio_balloon"
            "virtio_console"
            "virtio_rng"
            "scsi_mod"
            "sd_mod"
            "sr_mod"
          ];
      };

      qemuConf = {
        bios = "ovmf";
        cores = mkDefault cores;
        memory = mkDefault memory;
        boot = "order=scsi0";
        net0 = "virtio=00:00:00:00:00:00,bridge=vmbr0,firewall=1";
        primaryDisk = mkIf isOptimized "local-lvm:vm-9999-disk-0,discard=on,ssd=1,iothread=1";
      };

      qemuExtraConf = mkMerge [
        {
          tags = "nixos";
          cpu = "x86-64-v2-AES";
          machine =
            if isOptimized
            then "q35"
            else "i440fx";
        }
      ];

      partitionTableType = mkIf isOptimized "efi";
    };
  };
}
