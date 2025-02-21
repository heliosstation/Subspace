{config, ...}: 
let
  configPath = ./aerospace.toml;
in {
  xdg.configFile."aerospace/aerospace.toml".source = config.lib.file.mkOutOfStoreSymlink configPath;
}