# Based on [nixpkgs Proxmox image ](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/virtualisation/proxmox-image.nix
# Forking for enhancements that are geared towards my own home infrastructure
# and best practices. Key enhancements so far:
# - Set discard, ssd and iothread
# - Use ovmf
{
  nixpkgs,
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:
with lib; {
  imports = [
    "${modulesPath}/virtualisation/disk-size-option.nix"
    "${modulesPath}/image/file-options.nix"
    (lib.mkRenamedOptionModuleWith {
      sinceRelease = 2411;
      from = [
        "proxmox"
        "qemuConf"
        "diskSize"
      ];
      to = [
        "virtualisation"
        "diskSize"
      ];
    })
  ];

  options.proxmox = {
    diskType = mkOption {
      type = types.enum [
        "virtio"
        "scsi"
        "ide"
        "sata"
      ];
      default = "virtio";
      description = ''
        Type of disk to use. When using SCSI, optimized settings (discard=on, ssd=1, iothread=1) are applied.
      '';
    };

    kernelModules = {
      extraModules = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          Additional kernel modules to include in the image
        '';
      };

      extraInitrdModules = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          Additional initrd modules to include in the image
        '';
      };
    };

    qemuConf = {
      # essential configs
      boot = mkOption {
        type = types.str;
        default = "";
        example = "order=scsi0;net0";
        description = ''
          Default boot device. PVE will try all devices in its default order if this value is empty.
        '';
      };
      # essential configs
      scsihw = mkOption {
        type = types.str;
        default = "virtio-scsi-single";
        example = "lsi";
        description = ''
          SCSI controller type. Must be one of the supported values given in
          <https://pve.proxmox.com/wiki/Qemu/KVM_Virtual_Machines>
        '';
      };
      primaryDisk = mkOption {
        type = types.str;
        default = "local-lvm:vm-9999-disk-0";
        example = "ceph:vm-123-disk-0";
        description = ''
          Configuration for the primary disk. It can be used as a cue for PVE to autodetect the target storage.
          This parameter is required by PVE even if it isn't used. For disk type SCSI, optimizations are applied.
        '';
      };
      efiDisk = mkOption {
        type = types.str;
        default = "local-lvm:vm-9999-efidisk-0";
        example = "ceph:vm-123-efidisk-0";
        description = ''
          Configuration for the EFI disk. This defines the Proxmox storage target
          for the VM's EFI System Partition (ESP), typically required for UEFI boot.
          This disk holds the UEFI firmware variables (like NVRAM) and boot configuration
          data when using OVMF (UEFI). It is required if you enable UEFI boot with Proxmox.
        '';
      };
      ostype = mkOption {
        type = types.str;
        default = "l26";
        description = ''
          Guest OS type
        '';
      };
      cores = mkOption {
        type = types.ints.positive;
        default = 1;
        description = ''
          Guest core count
        '';
      };
      memory = mkOption {
        type = types.ints.positive;
        default = 1024;
        description = ''
          Guest memory in MB
        '';
      };
      bios = mkOption {
        type = types.enum [
          "seabios"
          "ovmf"
        ];
        default = "seabios";
        description = ''
          Select BIOS implementation (seabios = Legacy BIOS, ovmf = UEFI).
        '';
      };

      # optional configs
      name = mkOption {
        type = types.str;
        default = "nixos-${config.system.nixos.label}";
        description = ''
          VM name
        '';
      };
      additionalSpace = mkOption {
        type = types.str;
        default = "512M";
        example = "2048M";
        description = ''
          additional disk space to be added to the image if diskSize "auto"
          is used.
        '';
      };
      bootSize = mkOption {
        type = types.str;
        default = "256M";
        example = "512M";
        description = ''
          Size of the boot partition. Is only used if partitionTableType is
          either "efi" or "hybrid".
        '';
      };
      net0 = mkOption {
        type = types.commas;
        default = "virtio=00:00:00:00:00:00,bridge=vmbr0,firewall=1";
        description = ''
          Configuration for the default interface. When restoring from VMA, check the
          "unique" box to ensure device mac is randomized.
        '';
      };
      serial0 = mkOption {
        type = types.str;
        default = "socket";
        example = "/dev/ttyS0";
        description = ''
          Create a serial device inside the VM (n is 0 to 3), and pass through a host serial device (i.e. /dev/ttyS0),
          or create a unix socket on the host side (use qm terminal to open a terminal connection).
        '';
      };
      agent = mkOption {
        type = types.bool;
        apply = x:
          if x
          then "1"
          else "0";
        default = true;
        description = ''
          Expect guest to have qemu agent running
        '';
      };
    };
    qemuExtraConf = mkOption {
      type = with types;
        attrsOf (oneOf [
          str
          int
        ]);
      default = {};
      example = literalExpression ''
        {
          cpu = "host";
          onboot = 1;
        }
      '';
      description = ''
        Additional options appended to qemu-server.conf
      '';
    };
    partitionTableType = mkOption {
      type = types.enum [
        "efi"
        "hybrid"
        "legacy"
        "legacy+gpt"
      ];
      description = ''
        Partition table type to use. See make-disk-image.nix partitionTableType for details.
        Defaults to 'legacy' for 'proxmox.qemuConf.bios="seabios"' (default), other bios values defaults to 'efi'.
        Use 'hybrid' to build grub-based hybrid bios+efi images.
      '';
      default =
        if config.proxmox.qemuConf.bios == "seabios"
        then "legacy"
        else "efi";
      defaultText = lib.literalExpression ''if config.proxmox.qemuConf.bios == "seabios" then "legacy" else "efi"'';
      example = "hybrid";
    };
    filenameSuffix = mkOption {
      type = types.str;
      default = config.proxmox.qemuConf.name;
      example = "999-nixos_template";
      description = ''
        Filename of the image will be vzdump-qemu-''${filenameSuffix}.vma.zstd.
        This will also determine the default name of the VM on restoring the VMA.
        Start this value with a number if you want the VMA to be detected as a backup of
        any specific VMID.
      '';
    };
    cloudInit = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether the VM should accept cloud init configurations from PVE.
        '';
      };
      defaultStorage = mkOption {
        default = "local-lvm";
        example = "tank";
        type = types.str;
        description = ''
          Default storage name for cloud init drive.
        '';
      };
      device = mkOption {
        default = "ide2";
        example = "scsi0";
        type = types.str;
        description = ''
          Bus/device to which the cloud init drive is attached.
        '';
      };
    };
  };

  config = let
    cfg = config.proxmox;
    cfgLine = name: value: ''
      ${name}: ${builtins.toString value}
    '';

    inherit (cfg) partitionTableType;
    supportEfi = partitionTableType == "efi" || partitionTableType == "hybrid";
    supportBios =
      partitionTableType
      == "legacy"
      || partitionTableType == "hybrid"
      || partitionTableType == "legacy+gpt";
    hasBootPartition = partitionTableType == "efi" || partitionTableType == "hybrid";
    hasNoFsPartition = partitionTableType == "hybrid" || partitionTableType == "legacy+gpt";

    primaryDiskDevice = "${cfg.diskType}0";
    primaryDiskStorageTarget = builtins.head (builtins.split ":" cfg.qemuConf.primaryDisk);

    efiDiskDevice = "efidisk0";
    efiDiskStorageTarget = builtins.head (builtins.split ":" "local-lvm:vm-9999-efidisk-0");

    cfgFile = fileName: properties:
      pkgs.writeTextDir fileName ''
        # generated by NixOS
        ${lib.concatStrings (lib.mapAttrsToList cfgLine properties)}
        #qmdump#map:${primaryDiskDevice}:drive-${primaryDiskDevice}:${primaryDiskStorageTarget}:raw:
        ${lib.optionalString supportEfi "#qmdump#map:${efiDiskDevice}:drive-${efiDiskDevice}:${efiDiskStorageTarget}:raw:"}
      '';
  in {
    assertions = [
      {
        assertion = config.boot.loader.systemd-boot.enable -> config.proxmox.qemuConf.bios == "ovmf";
        message = "systemd-boot requires 'ovmf' bios";
      }
      {
        assertion = config.proxmox.qemuConf.efiDisk != null -> supportEfi;
        message = "'efi' disk partitioning requires 'efi' or 'hybrid' partitioning";
      }
      {
        assertion = partitionTableType == "efi" -> config.proxmox.qemuConf.bios == "ovmf";
        message = "'efi' disk partitioning requires 'ovmf' bios";
      }
      {
        assertion = partitionTableType == "legacy" -> config.proxmox.qemuConf.bios == "seabios";
        message = "'legacy' disk partitioning requires 'seabios' bios";
      }
      {
        assertion = partitionTableType == "legacy+gpt" -> config.proxmox.qemuConf.bios == "seabios";
        message = "'legacy+gpt' disk partitioning requires 'seabios' bios";
      }
    ];
    image.baseName = lib.mkDefault "vzdump-qemu-${cfg.filenameSuffix}";
    image.extension = "vma.zst";
    system.build.image = config.system.build.VMA;
    system.build.VMA = import "${toString nixpkgs}/nixos/lib/make-disk-image.nix" {
      name = "proxmox-${cfg.filenameSuffix}";
      baseName = config.image.baseName;
      inherit (cfg) partitionTableType;
      postVM = let
        # Build qemu with PVE's patch that adds support for the VMA format
        vma =
          (pkgs.qemu_kvm.override {
            alsaSupport = false;
            pulseSupport = false;
            sdlSupport = false;
            jackSupport = false;
            gtkSupport = false;
            vncSupport = false;
            smartcardSupport = false;
            spiceSupport = false;
            ncursesSupport = false;
            libiscsiSupport = false;
            tpmSupport = false;
            numaSupport = false;
            seccompSupport = false;
            guestAgentSupport = false;
          })
          .overrideAttrs
          (super: rec {
            # Check https://github.com/proxmox/pve-qemu/tree/master for the version
            # of qemu and patch to use
            version = "9.0.0";
            src = pkgs.fetchurl {
              url = "https://download.qemu.org/qemu-${version}.tar.xz";
              hash = "sha256-MnCKxmww2MiSYz6paMdxwcdtWX1w3erSGg0izPOG2mk=";
            };
            patches = [
              # Proxmox' VMA tool is published as a particular patch upon QEMU
              "${
                pkgs.fetchFromGitHub {
                  owner = "proxmox";
                  repo = "pve-qemu";
                  rev = "14afbdd55f04d250bd679ca1ad55d3f47cd9d4c8";
                  hash = "sha256-lSJQA5SHIHfxJvMLIID2drv2H43crTPMNIlIT37w9Nc=";
                }
              }/debian/patches/pve/0027-PVE-Backup-add-vma-backup-format-code.patch"
            ];

            buildInputs = super.buildInputs ++ [pkgs.libuuid];
            nativeBuildInputs = super.nativeBuildInputs ++ [pkgs.perl];
          });
      in ''
        ${lib.optionalString supportEfi ''
          ${pkgs.qemu}/bin/qemu-img create -f raw $out/efidisk.raw 4M
        ''}
        ${vma}/bin/vma create "${config.image.baseName}.vma" \
          -c ${
          cfgFile "qemu-server.conf" (
            removeAttrs cfg.qemuConf [
              "additionalSpace"
              "bootSize"
              "primaryDisk"
            ]
            // {
              "${cfg.diskType}0" = cfg.qemuConf.primaryDisk;
            }
            // lib.optionalAttrs supportEfi {
              "efidisk0" = "local-lvm:vm-9999-efidisk-0,efitype=4m,pre-enrolled-keys=0,size=4M";
            }
            // cfg.qemuExtraConf
          )
        }/qemu-server.conf \
        drive-${primaryDiskDevice}=$diskImage \
        ${lib.optionalString supportEfi "drive-${efiDiskDevice}=$out/efidisk.raw"}

        rm $diskImage
        ${lib.optionalString supportEfi ''
          rm $out/efidisk.raw
        ''}

        ${pkgs.zstd}/bin/zstd "${config.image.baseName}.vma"
        mv "${config.image.fileName}" $out/

        mkdir -p $out/nix-support
        echo "file vma $out/${config.image.fileName}" > $out/nix-support/hydra-build-products
      '';
      inherit (cfg.qemuConf) additionalSpace bootSize;
      inherit (config.virtualisation) diskSize;
      format = "raw";
      inherit config lib pkgs;
    };

    boot = {
      growPartition = true;
      kernelParams = ["console=ttyS0"];
      loader.grub = {
        device = lib.mkDefault (
          if (hasNoFsPartition || supportBios)
          then
            # Even if there is a separate no-fs partition ("/dev/disk/by-partlabel/no-fs" i.e. "/dev/vda2"),
            # which will be used the bootloader, do not set it as loader.grub.device.
            # GRUB installation fails, unless the whole disk is selected.
            "/dev/vda"
          else "nodev"
        );
        efiSupport = lib.mkDefault supportEfi;
        efiInstallAsRemovable = lib.mkDefault supportEfi;
      };

      loader.timeout = 0;
      initrd.availableKernelModules = [
        "uas"
        "virtio_blk"
        "virtio_pci"
      ] ++ cfg.kernelModules.extraModules;
      
      initrd.kernelModules = cfg.kernelModules.extraInitrdModules;
    };

    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos";
      autoResize = true;
      fsType = "ext4";
    };
    fileSystems."/boot" = lib.mkIf hasBootPartition {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };

    networking = mkIf cfg.cloudInit.enable {
      hostName = mkForce "";
      useDHCP = false;
    };

    services = {
      cloud-init = mkIf cfg.cloudInit.enable {
        enable = true;
        network.enable = true;
      };
      sshd.enable = mkDefault true;
      qemuGuest.enable = true;
    };

    proxmox.qemuExtraConf.${cfg.cloudInit.device} = "${cfg.cloudInit.defaultStorage}:vm-9999-cloudinit,media=cdrom";
  };
}
