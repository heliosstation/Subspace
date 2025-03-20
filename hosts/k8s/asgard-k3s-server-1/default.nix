{
  config,
  pkgs,
  sublib,
  subvars,
  disko,
  lib,
  ...
}: let
  hostName = "asgard-k3s-server-1";

  proxmoxModule = sublib.proxmoxVm {
    inherit pkgs hostName config sublib;
    inherit (subvars) networking;
  };

  k3sServerModule = sublib.k3sServer {
    inherit pkgs hostName;
    kubeconfigFile = "/home/${subvars.username}/.kube/config";
    #tokenFilePath = config.age.secrets."asgard-k3s-token".path;
    # use my own domain & kube-vip's virtual IP for the API server
    # so that the API server can always be accessed even if some nodes are down
    masterHost = "10.69.3.20";
    kubeletExtraArgs = [
      # https://kubernetes.io/docs/tasks/administer-cluster/reserve-compute-resources/
      # We have to reserve some resources for for system daemons running as pods or system services
      # when cpu-manager's static policy is enabled
      # the memory we reserved here is also for the kernel, since kernel's memory is not accounted in pods
      "--system-reserved=cpu=250m,memory=1Gi,ephemeral-storage=1Gi"
      "--kube-reserved=cpu=500m,memory=1Gi,ephemeral-storage=1Gi"
    ];
    nodeLabels = [
      "asgard.heliosstation.io/node-type=server"
      "asgard.heliosstation.io/proxmox-host=sgc"
    ];
    disableFlannel = true;
  };
in {
  imports =
    (sublib.scanPaths ./.)
    ++ [
      # disko.nixosModules.default
      # ../disk-configuration/k3s-server-disko-configuration.nix
      proxmoxModule
      k3sServerModule
    ];

  proxmox-vm-profile.template = lib.mkForce "proxmox-k3s-server";
}
