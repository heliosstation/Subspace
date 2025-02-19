{config, ...}: 
let
  configPath = "${config.home.homeDirectory}/Projects/Subspace/home/darwin/aerospace/aerospace.toml";
in {
  xdg.configFile."aerospace/aerospace.toml".source = config.lib.file.mkOutOfStoreSymlink configPath;
}