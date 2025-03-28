{
  # Network discovery, mDNS
  # With this enabled, you can access your machine at <hostname>.local
  # it's more convenient than using the IP address.
  # https://avahi.org/
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      domain = true;
      userServices = true;
    };
  };

  networking.timeServers = [
    "time.cloudflare.com" # Cloudflare NTP Server
    "time.aws.com" # Amazon Time Sync NTP Server
  ];
}