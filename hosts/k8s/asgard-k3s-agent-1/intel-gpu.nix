{
  config,
  pkgs,
  ...
}: {
  # Necessary to install GPU drivers
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    clinfo
    libva-utils
    intel-gpu-tools
  ];

  # Maybe needed to force intel-media-driver
  # environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };

  # Install Intel GPU Drivers
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      # Quick Sync Video
      vpl-gpu-rt

      # General Intel GPU iHD driver
      intel-media-driver

      # OpenCL runtime
      intel-compute-runtime

      # Use VDPAU (normally only supported on NVIDIA/AMD gpus on intel gpus)
      libvdpau-va-gl
    ];
  };
}
