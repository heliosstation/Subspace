{
  config,
  pkgs,
  sublib,
  hostName,
  networking,
  ...
}: let
  inherit (networking.hostsAddr.${hostName}) ipv4;
in {
  imports = map sublib.relativeToRoot [
    "modules/nixos/proxmox/proxmox-vm-profile.nix"
  ];
  # Supported file systems
  boot.supportedFilesystems = [
    "ext4"
    "xfs"
    "fat"
    "vfat"
    "exfat"
    "nfs"
  ];

  boot.kernelModules = ["kvm-amd" "vfio-pci"];
  boot.initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod"];
  boot.extraModprobeConfig = "options kvm_amd nested=1"; # for amd cpu
  # Enable serial console for Proxmox
  boot.kernelParams = ["console=ttyS0,115200n8"];
  # Clean /tmp folder on reboot
  boot.tmp.cleanOnBoot = true;
  ## Boot Configuration
  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
    };
    systemd-boot = {
      enable = true;
      configurationLimit = 3;
    };
  };
  # Making sure we're running latest linux kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernel.sysctl = {
    # --- Filesystem --- #
    # Increase the limits to avoid running out of inotify watches
    "fs.inotify.max_user_watches" = 524288;
    "fs.inotify.max_user_instances" = 1024;

    # --- Network --- #
    "net.bridge.bridge-nf-call-iptables" = 1;
    "net.core.somaxconn" = 32768;
    "net.ipv4.ip_forward" = 1;
    "net.ipv4.conf.all.forwarding" = 1;
    "net.ipv4.neigh.default.gc_thresh1" = 4096;
    "net.ipv4.neigh.default.gc_thresh2" = 6144;
    "net.ipv4.neigh.default.gc_thresh3" = 8192;
    "net.ipv4.neigh.default.gc_interval" = 60;
    "net.ipv4.neigh.default.gc_stale_time" = 120;

    # Disable IPv6 since we are not planning on using it
    "net.ipv6.conf.all.disable_ipv6" = 1;

    # --- Memory --- #
    # Don't swap unless absolutely necessary
    "vm.swappiness" = 0;
  };

  # Allow firmware even with license
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

  # Enable QEMU guest agent for better VM integration
  services.qemuGuest.enable = true;
  # Enable fstrim so that discarded blocks are recovered on the host
  services.fstrim.enable = true;
  # Longhorn uses open-iscsi to create block devices.
  services.openiscsi = {
    name = "iqn.2025-03.io.heliosstation:${hostName}";
    enable = true;
  };

  proxmox.cloudInit.enable = false;
  services.cloud-init.enable = false;

  # Enable watchdog
  systemd.watchdog.device = "/dev/watchdog";
  systemd.watchdog.runtimeTime = "30s";

  # Workaround for longhorn running on NixOS
  # https://github.com/longhorn/longhorn/issues/2166
  systemd.tmpfiles.rules = [
    "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
  ];

  # Networking config
  networking = {
    inherit hostName;
    inherit (networking) defaultGateway nameservers;

    interfaces."enp6s18" = {
      ipv4.addresses = [
        {
          address = ipv4;
          prefixLength = 24;
        }
      ];
    };
    networkmanager.enable = false;
    dhcpcd.enable = false;
    enableIPv6 = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
