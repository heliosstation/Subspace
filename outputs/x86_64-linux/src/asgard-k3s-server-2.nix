{
  # NOTE: the args not used in this file CAN NOT be removed!
  # because haumea pass argument lazily,
  # and these arguments are used in the functions like `sublib.nixosSystem`, `sublib.colmenaSystem`, etc.
  inputs,
  lib,
  sublib,
  subvars,
  system,
  genSpecialArgs,
  ...
} @ args: let
  name = "asgard-k3s-server-2";
  tags = [name];
  ssh-user = "root";

  modules = {
    nixos-modules =
      (map sublib.relativeToRoot [
        # Common
        "secrets/nixos.nix"
        "modules/nixos/server/server.nix"
        # Host specific
        "hosts/k8s/${name}"
      ])
      ++ [
        {modules.secrets.server.kubernetes.enable = true;}
      ];
    home-modules = map sublib.relativeToRoot [
      "home/linux/default.nix"
    ];
  };

  systemArgs = modules // args;
in {
  nixosConfigurations.${name} = sublib.nixosSystem systemArgs;

  colmena.${name} =
    sublib.colmenaSystem (systemArgs // {inherit tags ssh-user;});

  packages.${name} = inputs.self.nixosConfigurations.${name}.config.system.build.VMA;
}
