{
  subvars,
  lib,
}: let
  username = subvars.username;
  hosts = [
    "dhd"
  ];
in
  lib.genAttrs hosts (_: "/Users/${username}")
