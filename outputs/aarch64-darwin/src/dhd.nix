{
  # NOTE: the args not used in this file CAN NOT be removed!
  # because haumea pass argument lazily,
  # and these arguments are used in the functions like `.nixosSystem`, `sublib.colmenaSystem`, etc.
  inputs,
  lib,
  sublib,
  subvars,
  system,
  genSpecialArgs,
  ...
} @ args: let
  name = "dhd";

  modules = {
    darwin-modules =
      (map sublib.relativeToRoot [
        # common
        "secrets/darwin.nix"
        "modules/darwin"
        # host specific
        "hosts/darwin-${name}"
      ])
      ++ [];
    home-modules = map sublib.relativeToRoot [
      "hosts/darwin-${name}/home.nix"
      "home/darwin"
    ];
  };

  systemArgs = modules // args;
in {
  # macOS's configuration
  darwinConfigurations.${name} = sublib.darwinSystem systemArgs;
}
