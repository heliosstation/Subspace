{
  config,
  pkgs,
  ...
}: {
  # Necessary to install GPU drivers
  nixpkgs.config.allowUnfree = true;
  # Use of NVIDIA Software requires license acceptance
  nixpkgs.config.nvidia.acceptLicense = true;

  environment.systemPackages = with pkgs; [
    nvtop
  ];

  # Enable hardware accelerated graphics drivers
  #
  hardware.graphics.enable = true;

  # Install Intel GPU Drivers
  # https://nixos.wiki/wiki/Nvidia
  hardware.nvidia = {
    # Modesetting is required.
    # Enable kernel modesetting when using the NVIDIA proprietary driver.
    # Enabling this fixes screen tearing when using Optimus via PRIME
    # (see hardware.nvidia.prime.sync.enable. This is not enabled by default
    # because it is not officially supported by NVIDIA and would not work with SLI.
    # Enabling this and using version 545 or newer of the proprietary NVIDIA driver
    # causes it to provide its own framebuffer device, which can cause Wayland
    # compositors to work when they otherwise wouldn’t.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    # For GPUs Turing and later recommended by NVIDIA to set true
    open = true;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # It ensures all GPUs stay awake even during headless mode .
    nvidiaPersistenced = true;

    # Enable Data Center drivers for NVIDIA cards on a NVLink topology
    # Required for nvidia-container-toolkit
    datacenter.enable = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.dc_535;
  };

  hardware.nvidia-container-toolkit = {
    # Enable dynamic CDI configuration for Nvidia devices by running nvidia-container-toolkit on boot.
    enable = true;

    # Mount executables nvidia-smi, nvidia-cuda-mps-control, nvidia-cuda-mps-server,
    # nvidia-debugdump, nvidia-powerd and nvidia-ctk on containers.
    mount-nvidia-executables = true;
  };
}
