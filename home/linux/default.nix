{
  sublib,
  subvars,
  ...
}: {
  imports =
    [
      ../base/core
      ../base/home.nix
    ]
    ++ (sublib.scanPaths ./.);
}
