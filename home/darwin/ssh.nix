{subvars, ...}: {
  programs.ssh.extraConfig = subvars.networking.ssh.extraConfig;
}
