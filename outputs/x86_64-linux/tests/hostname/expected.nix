{
  lib,
  outputs,
}: let
  # In case we had some special hostNames
  specialExpected = {};
  specialHostNames = builtins.attrNames specialExpected;

  otherHosts = builtins.removeAttrs outputs.nixosConfigurations specialHostNames;
  otherHostsNames = builtins.attrNames otherHosts;
  # other hosts's hostName is the same as the nixosConfigurations name
  otherExpected = lib.genAttrs otherHostsNames (name: name);
in (specialExpected // otherExpected)
