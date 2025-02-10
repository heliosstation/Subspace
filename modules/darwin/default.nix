{sublib, ...}: {
  imports =
    (sublib.scanPaths ./.)
    ++ [
      ../base.nix
    ];
}
