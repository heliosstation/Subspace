{
  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host shepherd
        Hostname 10.69.3.102
        IdentityFile ~/.ssh/github-heliosstation
        IdentitiesOnly yes

      Host github.com
        Hostname github.com
        # github is controlled by dhd~
        IdentityFile ~/.ssh/github-heliosstation
        # Specifies that ssh should only use the identity file explicitly configured above
        # required to prevent sending default identity files first.
        IdentitiesOnly yes
        AddKeysToAgent yes

      Host gitea.local.heliosstation.io
        Hostname gitea.local.heliosstation.io
        # gitea is controlled by dhd~
        IdentityFile ~/.ssh/gitea-heliosstation
        # Specifies that ssh should only use the identity file explicitly configured above
        # required to prevent sending default identity files first.
        IdentitiesOnly yes
        AddKeysToAgent yes
    '';
  };
}
