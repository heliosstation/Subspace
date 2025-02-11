{
  config,
  lib,
  pkgs,
  subvars,
  ...
}: {
  # `programs.git` will generate the config file: ~/.config/git/config
  # to make git use this config file, `~/.gitconfig` should not exist!
  #
  #    https://git-scm.com/docs/git-config#Documentation/git-config.txt---global
  home.activation.removeExistingGitconfig = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
    rm -f ${config.home.homeDirectory}/.gitconfig
  '';

  home.packages = with pkgs; [];

  programs.git = {
    enable = true;
    lfs.enable = true;

    userName = subvars.userfullname;
    userEmail = subvars.useremail;

    extraConfig = {
      init.defaultBranch = "main";
      trim.bases = "develop,master,main";
      push.autoSetupRemote = true;
      pull.rebase = true;

      url = {
        "ssh://git@github.com/heliosstation" = {
          insteadOf = "https://github.com/heliosstation";
        };
        "ssh://gitea@10.69.3.8/helios" = {
          insteadOf = "https://gitea.local.heliosstation.io/helios";
        };
      };
    };

    signing = {
      key = "92B78F349AD4A03B";
      signByDefault = true;
    };
  };
}
