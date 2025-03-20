{
  pkgs,
  kubeconfigFile,
  tokenFile ? null,
  # Initialize HA cluster using an embedded etcd datastore.
  # If you are configuring an HA cluster with an embedded etcd,
  # the 1st server must have `clusterInit = true`
  # and other servers must connect to it using `serverAddr`.
  #
  # This can be a domain name or an IP address(such as kube-vip's virtual IP)
  masterHost,
  clusterInit ? false,
  kubeletExtraArgs ? [],
  nodeLabels ? [],
  nodeTaints ? [],
  disableFlannel ? true,
  hostName,
  ...
}: let
  lib = pkgs.lib;
  package = pkgs.k3s;
  hostIndex = builtins.head (builtins.match ".*-([0-9]+)$" hostName);
in {
  environment.systemPackages = with pkgs; [
    package
    k9s
    kubectl
    istioctl
    kubernetes-helm
    cilium-cli
    argocd
    clusterctl
    containerd

    skopeo
    go-containerregistry
    dive
  ];

  services.k3s = {
    enable = true;
    inherit package tokenFile clusterInit;
    serverAddr =
      if clusterInit
      then ""
      else "https://${masterHost}:6443";

    role = "server";
    # https://docs.k3s.io/cli/server
    extraFlags = let
      flagList =
        [
          "--write-kubeconfig=${kubeconfigFile}"
          "--write-kubeconfig-mode=644"
          "--service-node-port-range=80-32767"
          "--data-dir /var/lib/rancher/k3s"
          "--etcd-expose-metrics=true"
          "--etcd-snapshot-schedule-cron='0 */12 * * *'"
          # Disable features we don't need
          # We use ArgoCD instead
          "--disable-helm-controller"
          # We will install Ingress Controller via ArgoCD
          "--disable=traefik"
          # We will install MetalLB via ArgoCD
          "--disable=servicelb"
          "--disable-network-policy"
          "--tls-san=${masterHost}"
        ]
        ++ (map (label: "--node-label=${label}") nodeLabels)
        ++ (map (taint: "--node-taint=${taint}") nodeTaints)
        ++ (map (arg: "--kubelet-arg=${arg}") kubeletExtraArgs)
        ++ (lib.optionals disableFlannel ["--flannel-backend=none"]);
    in
      lib.concatStringsSep " " flagList;
  };

  networking.firewall.allowedTCPPorts = [
    6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
    2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
    2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
  ];

  fileSystems."/var/lib/rancher/k3s" = {
    device = "/dev/disk/by-label/K3S_${hostIndex}";
    fsType = "ext4";
    options = ["noatime"];
  };

  # Create symlinks to link k3s's CNI directory to the one used by almost all
  # CNI plugins such as multus, calico, etc.
  # https://www.freedesktop.org/software/systemd/man/latest/tmpfiles.d.html#Type
  systemd.tmpfiles.rules = [
    "L+ /opt/cni/bin - - - - /var/lib/rancher/k3s/data/current/bin"
    # If you have disabled flannel, you will have to create the directory via a tmpfiles rule
    "d /var/lib/rancher/k3s/agent/etc/cni/net.d 0751 root root - -"
    # Link the CNI config directory
    "L+ /etc/cni/net.d - - - - /var/lib/rancher/k3s/agent/etc/cni/net.d"
  ];
}
