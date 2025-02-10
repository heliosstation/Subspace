_:
#############################################################
#
#  DHD - MacBook Pro 2021 14-inch M1 16G
#
#############################################################
let
  hostname = "dhd";
in {
  networking.hostName = hostname;
  networking.computerName = hostname;
  system.defaults.smb.NetBIOSName = hostname;
}
