{
  subvars,
  lib,
  outputs,
}: let
  username = subvars.username;
  hosts = [
    "dhd"
  ];
in
  lib.genAttrs
  hosts
  (
    name: outputs.darwinConfigurations.${name}.config.home-manager.users.${username}.home.homeDirectory
  )
