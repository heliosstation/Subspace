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
    # shepherd = {
    #   ipv4 = "10.69.3.102";
    # };

    # ============================================
    # Kubernetes Clusters
    # ============================================
    # IP range reserved for the K8s cluster nodes:
    # 10.69.3.20 - 10.69.3.49
    # Server Nodes: 10.69.3.20 - 10.69.3.29
    asgard-k3s-server-0 = {
      ipv4 = "10.69.3.20";
    };
    asgard-k3s-server-1 = {
      ipv4 = "10.69.3.21";
    };
    asgard-k3s-server-2 = {
      ipv4 = "10.69.3.22";
    };
    # Server Nodes: 10.69.3.30 - 10.69.3.49
    asgard-k3s-agent-0 = {
      ipv4 = "10.69.3.30";
    };
    asgard-k3s-agent-1 = {
      ipv4 = "10.69.3.31";
    };
    asgard-k3s-agent-2 = {
      ipv4 = "10.69.3.32";
    };
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
        # shepherd.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILq2LZDtOeS8MTYrDtj9CmvZ5eSAdUzalOtyrP1dixyT shepherd@nix-builder";
        # sgc.publicKey = "";
        # atlantis.publicKey = "";
      };
  };
}
