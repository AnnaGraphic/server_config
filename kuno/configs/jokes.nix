{ pkgs, ... }: {
  networking.firewall.allowedTCPPorts = [
    80
  ];
  services.ferretdb.enable = true;
  services.nginx.enable = true;
  services.nginx.virtualHosts."jokes.panda.krebsco.de" = {
    listen = [
      { addr = "0.0.0.0"; port = 80; }
    ];
    # locations."/".root = "${pkgs.jokes}/lib/client";
    locations."/api" = {
      proxyPass = "http://127.0.0.1:4001";
      extraConfig = ''
        add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
        add_header Access-Control-Allow-Origin "*" always;
      '';
    };
  };
  systemd.services.jokes-server = {
    wantedBy = [ "multi-user.target" ];
    environment = {
      HOME = "/var/cache/jokes";
      PORT = "4001";
    };
    serviceConfig = {
      CacheDirectory = "jokes";
      WorkingDirectory = "/var/cache/jokes";
      ExecStart = "${pkgs.jokes}/bin/jokes-server";
      DynamicUser = true;
      User = "jokes";
    };
  };
}
