{
  subvars,
  lib,
}: let
  username = subvars.username;
  hosts = [
    "asgard-k3s-server-0"
  ];
in
  lib.genAttrs hosts (_: "/home/${username}")
