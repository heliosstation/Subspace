{
  subvars,
  lib,
  outputs,
}: let
  username = subvars.username;
  hosts = [
    "asgard-k3s-server-0"
  ];
in
  lib.genAttrs
  hosts
  (
    name: outputs.nixosConfigurations.${name}.config.home-manager.users.${username}.home.homeDirectory
  )
