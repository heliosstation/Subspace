{ 
  config, 
  pkgs, 
  ... 
} @args:
{
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = true;
      allowInsecure = false;
      allowUnsupportedSystem = true;
    };

    overlays = (import ../../overlays args);
  };
}
