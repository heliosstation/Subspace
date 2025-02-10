{
  sublib,
  subvars,
  ...
}: {
  home.homeDirectory = "/Users/${subvars.username}";
  imports =
    (sublib.scanPaths ./.)
    ++ [
      ../base/core
      ../base/tui
      ../base/gui
      ../base/home.nix
    ];

  # Enable management of XDG base directories on macOS.
  xdg.enable = true;
}
