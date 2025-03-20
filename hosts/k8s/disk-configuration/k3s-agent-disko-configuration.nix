{
  disko.devices = {
    # Main disk configuration (Root, Boot)
    disk.main = {
      type = "disk";
      device = "/dev/vda";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["defaults"];
              extraArgs = ["-LESP"];
            };
          };
          root = {
            size = "32G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = ["noatime"];
              extraArgs = ["-Lnixos"];
            };
          };
        };
      };
    };
  };
}
