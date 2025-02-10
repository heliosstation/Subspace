{
  config,
  pkgs,
  agenix,
  subsecrets,
  subvars,
  ...
}: {
  imports = [
    agenix.darwinModules.default
  ];

  # enable logs for debugging
  launchd.daemons."activate-agenix".serviceConfig = {
    StandardErrorPath = "/Library/Logs/org.nixos.activate-agenix.stderr.log";
    StandardOutPath = "/Library/Logs/org.nixos.activate-agenix.stdout.log";
  };

  environment.systemPackages = [
    agenix.packages."${pkgs.system}".default
  ];

  # if you changed this key, you need to regenerate all encrypt files from the decrypt contents!
  age.identityPaths = [
    # Generate manually via `sudo ssh-keygen -A`
    "/etc/ssh/ssh_host_ed25519_key" # macOS, using the host key for decryption
  ];

  age.secrets = let
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
    # ---------------------------------------------
    # GitHub SSH Key (for GitHub authentication)
    # ---------------------------------------------
    "github-signing-key" =
      {
        file = "${subsecrets}/github-signing-key.age";
      }
      // user_readable;

    # ---------------------------------------------
    # GitHub Signing Key (for signed commits)
    # ---------------------------------------------
    "github-ssh-key" =
      {
        file = "${subsecrets}/github-ssh-key.age";
      }
      // user_readable;
  };

  # Place secrets in /etc/
  # NOTE: this will fail for the first time. cause it's running before "activate-agenix"
  environment.etc = {
    "agenix/github-signing-key" = {
      source = config.age.secrets."github-signing-key".path;
    };

    "agenix/github-ssh-key" = {
      source = config.age.secrets."github-ssh-key".path;
    };
  };

  # both the original file and the symlink should be readable and executable by the user
  #
  # activationScripts are executed every time you run `nixos-rebuild` / `darwin-rebuild` or boot your system
  system.activationScripts.postActivation.text = ''
    ${pkgs.nushell}/bin/nu -c '
      if (ls /etc/agenix/ | length) > 0 {
        sudo chown ${subvars.username} /etc/agenix/*
      }
    '
  '';
}
