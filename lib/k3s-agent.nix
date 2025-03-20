{
  pkgs,
  masterHost,
  tokenFile ? null,
  nodeLabels ? [],
  hostName,
  kubeletExtraArgs,
  containerdConfigTemplate ? null,
  ...
}: let
  package = pkgs.k3s;
  hostIndex = builtins.head (builtins.match ".*-([0-9]+)$" hostName);
in {
  environment.systemPackages = with pkgs; [
    package
    containerd
    kubernetes-helm
  ];

  services.k3s = {
    enable = true;
    inherit package tokenFile containerdConfigTemplate;

    role = "agent";
    serverAddr = "https://${masterHost}:6443";
    # https://docs.k3s.io/cli/agent
    extraFlags = let
      flagList =
        [
          "--data-dir /var/lib/rancher/k3s"
        ]
        ++ (map (arg: "--kubelet-arg=${arg}") kubeletExtraArgs)
        ++ (map (label: "--node-label=${label}") nodeLabels);
    in
      pkgs.lib.concatStringsSep " " flagList;
  };

  networking.firewall.allowedTCPPorts = [
    6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
    2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
    2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
  ];

  fileSystems."/var/lib/longhorn" = {
    device = "/dev/disk/by-label/LH_K3S_${hostIndex}";
    fsType = "xfs";
    options = ["noatime" "discard"];
  };
}
