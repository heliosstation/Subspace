{
  config,
  subvars,
  pkgs,
  ...
}: let
  homeDir = config.users.users."${subvars.username}".home;
in {
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = false;
  };

  launchd.user.agents.gnupg-agent.serviceConfig = {
    StandardErrorPath = "${homeDir}/Library/Logs/gnupg-agent.stderr.log";
    StandardOutPath = "${homeDir}/Library/Logs/gnupg-agent.stdout.log";
  };

  environment.etc."ssh/sshd_config.d/200-disable-password-auth.conf".text = ''
    PasswordAuthentication no
    KbdInteractiveAuthentication no
  '';
}
