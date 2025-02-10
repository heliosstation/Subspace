{lib}: rec {
  mainGateway = "10.69.1.1"; # Unifi
  defaultGateway = "10.69.1.1";
  nameservers = [
    "10.69.1.50" # PiHole - Prime
    "10.69.3.50" # PiHole - Secondary
  ];
  prefixLength = 24;

  hostsAddr = {
    # ============================================
    # Homelab's Physical Machines (KubeVirt Nodes)
    # ============================================
    sgc = {
      ipv4 = "10.69.3.3";
    };
    atlantis = {
      ipv4 = "10.69.3.5";
    };
    iris = {
      ipv4 = "10.69.1.50";
    };
    anubis = {
      ipv4 = "10.69.3.50";
    };

    # ============================================
    # Other VMs and Physical Machines
    # ============================================
    stargate = {
      ipv4 = "10.69.3.10";
    };
    icarus = {
      ipv4 = "10.69.3.61";
    };
    zpm = {
      ipv4 = "10.69.3.6";
    };

    # ============================================
    # Kubernetes Clusters
    # ============================================
    # TODO: Add Kubernetes Cluster nodes here
  };

  # TODO: Enable for host/VM configuration
  # hostsInterface =
  #   lib.attrsets.mapAttrs
  #   (
  #     key: val: {
  #       interfaces."${val.iface}" = {
  #         useDHCP = false;
  #         ipv4.addresses = [
  #           {
  #             inherit prefixLength;
  #             address = val.ipv4;
  #           }
  #         ];
  #       };
  #     }
  #   )
  #   hostsAddr;

  ssh = {
    # define the host alias for remote builders
    # this config will be written to /etc/ssh/ssh_config
    # ''
    #   Host ruby
    #     HostName 192.168.5.102
    #     Port 22
    #
    #   Host kana
    #     HostName 192.168.5.103
    #     Port 22
    #   ...
    # '';
    extraConfig =
      lib.attrsets.foldlAttrs
      (acc: host: val:
        acc
        + ''
          Host ${host}
            HostName ${val.ipv4}
            Port 22
        '')
      ""
      hostsAddr;

    # Define the host key for remote builders so that nix can verify all the remote builders
    # this config will be written to /etc/ssh/ssh_known_hosts
    # TODO: Setup remote builders
    knownHosts =
      # Update only the values of the given attribute set.
      #
      #   mapAttrs
      #   (name: value: ("bar-" + value))
      #   { x = "a"; y = "b"; }
      #     => { x = "bar-a"; y = "bar-b"; }
      lib.attrsets.mapAttrs
      (host: value: {
        hostNames = [host hostsAddr.${host}.ipv4];
        publicKey = value.publicKey;
      })
      {
        # sgc.publicKey = "";
        # atlantis.publicKey = "";
      };
  };
}
