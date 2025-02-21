{ config, ... }: 
{
  # TODO: Migrate to lua using SbarLua
  xdg.configFile = {
    "sketchybar/plugins/battery.sh" = {
      source = config.lib.file.mkOutOfStoreSymlink ./plugins/battery.sh;
      executable = true;
    };
    "sketchybar/plugins/clock.sh" = {
      source = ./plugins/clock.sh;
      executable = true;
    };
    "sketchybar/plugins/front_app.sh" = {
      source = ./plugins/front_app.sh;
      executable = true;
    };
    "sketchybar/plugins/space.sh" = {
      source = ./plugins/space.sh;
      executable = true;
    };
    "sketchybar/plugins/volume.sh" = {
      source = config.lib.file.mkOutOfStoreSymlink ./plugins/volume.sh;
      executable = true;
    };
    "sketchybar/sketchybarrc" = {
      source = config.lib.file.mkOutOfStoreSymlink ./sketchybarrc;
      executable = true;
    };
  };
}