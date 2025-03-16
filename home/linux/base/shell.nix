{
  config,
  subvars,
  ...
}: let
  dataHome = config.xdg.dataHome;
  configHome = config.xdg.configHome;
  cacheHome = config.xdg.cacheHome;
in {
  home.homeDirectory = "/home/${subvars.username}";

  # environment variables that always set at login
  home.sessionVariables = {
    # clean up ~
    LESSHISTFILE = cacheHome + "/less/history";
    LESSKEY = configHome + "/less/lesskey";

    # set default applications
    BROWSER = "firefox";

    # enable scrolling in git diff
    DELTA_PAGER = "less -R";
  };
}