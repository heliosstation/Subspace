{
  lib,
  config,
  pkgs,
  agenix,
  subsecrets,
  subvars,
  ...
}:
with lib; let
  cfg = config.modules.secrets;

  enabledServerSecrets =
    cfg.server.application.enable
    || cfg.server.network.enable
    || cfg.server.operation.enable
    || cfg.server.kubernetes.enable
    || cfg.server.webserver.enable
    || cfg.server.storage.enable;

  noaccess = {
    mode = "0000";
    owner = "root";
  };
  high_security = {
    mode = "0500";
    owner = "root";
  };
  user_readable = {
    mode = "0500";
    owner = subvars.username;
  };
in {
  imports = [
    agenix.nixosModules.default
  ];

  options.modules.secrets = {
    desktop.enable = mkEnableOption "NixOS Secrets for Desktops";

    server.network.enable = mkEnableOption "NixOS Secrets for Network Servers";
    server.application.enable = mkEnableOption "NixOS Secrets for Application Servers";
    server.operation.enable = mkEnableOption "NixOS Secrets for Operation Servers(Backup, Monitoring, etc)";
    server.kubernetes.enable = mkEnableOption "NixOS Secrets for Kubernetes";
    server.webserver.enable = mkEnableOption "NixOS Secrets for Web Servers(contains tls cert keys)";
    server.storage.enable = mkEnableOption "NixOS Secrets for HDD Data's LUKS Encryption";

    impermanence.enable = mkEnableOption "whether use impermanence and ephemeral root file system";
  };

  config = mkIf (cfg.desktop.enable || enabledServerSecrets) (mkMerge [
    {
      environment.systemPackages = [
        agenix.packages."${pkgs.system}".default
      ];

      # if you changed this key, you need to regenerate all encrypt files from the decrypt contents!
      age.identityPaths =
        if cfg.impermanence.enable
        then [
          # To decrypt secrets on boot, this key should exists when the system is booting,
          # so we should use the real key file path(prefixed by `/persistent/`) here, instead of the path mounted by impermanence.
          "/persistent/etc/ssh/ssh_host_ed25519_key" # Linux
        ]
        else [
          "/etc/ssh/ssh_host_ed25519_key"
        ];

      assertions = [
        {
          # This expression should be true to pass the assertion
          assertion = !(cfg.desktop.enable && enabledServerSecrets);
          message = "Enable either desktop or server's secrets, not both!";
        }
      ];
    }

    (mkIf cfg.desktop.enable {
      age.secrets = {
        # TODO: Add SMB credentials
        # Used only by NixOS Modules
        # smb-credentials is referenced in /etc/fstab, by ../hosts/ai/cifs-mount.nix
        # "smb-credentials" =
        #   {
        #     file = "${subsecrets}/smb-credentials.age";
        #   }
        #   // high_security;

        # ---------------------------------------------
        # GitHub SSH Key (for GitHub authentication)
        # ---------------------------------------------
        "github-signing-key.age" =
          {
            file = "${subsecrets}/github-signing-key.age";
          }
          // user_readable;

        # ---------------------------------------------
        # GitHub Signing Key (for signed commits)
        # ---------------------------------------------
        "github-ssh-key.age" =
          {
            file = "${subsecrets}/github-ssh-key.age";
          }
          // user_readable;
      };

      # place secrets in /etc/
      environment.etc = {
        "agenix/github-signing-key" = {
          source = config.age.secrets."github-signing-key".path;
        };

        "agenix/github-ssh-key" = {
          source = config.age.secrets."github-ssh-key".path;
        };
      };
    })

    (mkIf cfg.server.network.enable {
      age.secrets = {
      };
    })

    (mkIf cfg.server.application.enable {
      age.secrets = {
        # TODO: Add application secrets
        # "transmission-credentials.json" =
        #   {
        #     file = "${subsecrets}/server/transmission-credentials.json.age";
        #   }
        #   // high_security;

        # "sftpgo.env" = {
        #   file = "${subsecrets}/server/sftpgo.env.age";
        #   mode = "0400";
        #   owner = "sftpgo";
        # };
        # "minio.env" = {
        #   file = "${subsecrets}/server/minio.env.age";
        #   mode = "0400";
        #   owner = "minio";
        # };
      };
    })

    (mkIf cfg.server.operation.enable {
      age.secrets = {
        # TODO: Add monitoring services secrets
        # "grafana-admin-password" = {
        #   file = "${subsecrets}/server/grafana-admin-password.age";
        #   mode = "0400";
        #   owner = "grafana";
        # };

        # "alertmanager.env" =
        #   {
        #     file = "${subsecrets}/server/alertmanager.env.age";
        #   }
        #   // high_security;
      };
    })

    (mkIf cfg.server.kubernetes.enable {
      age.secrets = {
        # TODO: Add Kubernetes token
        # "k8s-token" =
        #   {
        #     file = "${subsecrets}/server/k8s-token.age";
        #   }
        #   // high_security;
      };
    })

    (mkIf cfg.server.webserver.enable {
      age.secrets = {
        # Add DB secrets key
        # "postgres-ecc-server.key" = {
        #   file = "${subsecrets}/certs/ecc-server.key.age";
        #   mode = "0400";
        #   owner = "postgres";
        # };
      };
    })

    (mkIf cfg.server.storage.enable {
      age.secrets = {
        # TODO: Add LUKS encryption key
        # "hdd-luks-crypt-key" = {
        #   file = "${subsecrets}/hdd-luks-crypt-key.age";
        #   mode = "0400";
        #   owner = "root";
        # };
      };

      # place secrets in /etc/
      environment.etc = {
        # TODO: Add LUKS encryption key
        # "agenix/hdd-luks-crypt-key" = {
        #   source = config.age.secrets."hdd-luks-crypt-key".path;
        #   mode = "0400";
        #   user = "root";
        # };
      };
    })
  ]);
}
