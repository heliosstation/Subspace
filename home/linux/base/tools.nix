{pkgs, ...}: {
  # Linux Only Packages, not available on Darwin
  home.packages = with pkgs; [
    # misc
    libnotify
    wireguard-tools # manage wireguard vpn manually, via wg-quick

    ventoy # create bootable usb
  ];

  # Auto mount usb drives
  services = {
    udiskie.enable = true;
  };
}
