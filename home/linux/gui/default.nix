{
  sublib,
  subvars,
  ...
}: {
  imports =
    [
      ../../base/core
      ../../base/tui
      ../../base/gui
      ../../base/home.nix
      ../base
    ]
    ++ (sublib.scanPaths ./.);
}
