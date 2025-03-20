{
  config,
  pkgs,
  subvars,
  sublib,
  disko,
  lib,
  ...
}: let
  hostName = "asgard-k3s-agent-2";

  coreModule = sublib.proxmoxVm {
    inherit pkgs hostName config sublib;
    inherit (subvars) networking;
  };
  k3sModule = sublib.k3sAgent {
    inherit pkgs hostName;
    #tokenFilePath = config.age.secrets."asgard-k3s-token".path;
    # use my own domain & kube-vip's virtual IP for the API server
    # so that the API server can always be accessed even if some nodes are down
    masterHost = "10.69.3.20";
    kubeletExtraArgs = [
      "--feature-gates=DevicePlugins=true"
      "--cpu-manager-policy=static"
      # https://kubernetes.io/docs/tasks/administer-cluster/reserve-compute-resources/
      # We have to reserve some resources for for system daemons running as pods or system services
      # when cpu-manager's static policy is enabled
      # the memory we reserved here is also for the kernel, since kernel's memory is not accounted in pods
      "--system-reserved=cpu=500m,memory=1.5Gi,ephemeral-storage=2Gi"
      "--kube-reserved=cpu=500m,memory=2Gi,ephemeral-storage=2Gi"
    ];
    nodeLabels = [
      "asgard.heliosstation.io/node-type=agent"
      "asgard.heliosstation.io/proxmox-host=atlantis"
      "asgard.heliosstation.io/gpu=nvidia-2080ti"
    ];
    # Enable Nvidia Container Runtime
    # https://docs.k3s.io/advanced#configuring-containerd
    #
    containerdConfigTemplate = ''
      {{ template "base" . }}
      [plugins]
        "io.containerd.grpc.v1.cri".enable_cdi = true

      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia]
        privileged_without_host_devices = false
        runtime_engine = ""
        runtime_root = ""
        runtime_type = "io.containerd.runc.v2"

      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia.options]
        BinaryName = "/run/current-system/sw/bin/nvidia-container-runtime"
    '';
  };
in {
  imports =
    (sublib.scanPaths ./.)
    ++ [
      # disko.nixosModules.default
      # ../disk-configuration/k3s-agent-disko-configuration.nix
      coreModule
      k3sModule
    ];
  boot.kernelParams = [
    # Disable transparent hugepage (allocate hugepages dynamically)
    # https://www.kernel.org/doc/html/next/admin-guide/mm/transhuge.html
    "transparent_hugepage=never"

    # Pre-allocate hugepages manually
    # NOTE: The hugepages allocated here can not be used for other purposes!
    "default_hugepagesz=2M" # Default HugePage size set to 2MB

    "hugepagesz=2M" # Enable 2MB HugePages
    "hugepages=512" # Allocate 512 pages (1GB/24GB total)

    # For AI/HPC Workloads
    # TODO: Revisit and increase this if needed
    "hugepagesz=1G" # Enable 1GB HugePages
    "hugepages=8" # Allocate 8 pages (8GB/24GB total)
  ];

  proxmox-vm-profile.template = lib.mkForce "proxmox-k3s-agent";
}
