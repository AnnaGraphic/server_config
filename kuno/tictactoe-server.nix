{ pkgs, ... }: {
  networking.firewall.allowedTCPPorts = [
    80
    4000
  ];
  services.nginx.enable = true;
  services.nginx.virtualHosts._default = {
    listen = [
      { addr = "0.0.0.0"; port = 80; }
    ];
    locations."/".proxyPass = "http://127.0.0.1:3333";
  };
  services.postgresql.enable = true;
  services.postgresql.ensureDatabases = [
    "tictactoe"
  ];
  services.postgresql.ensureUsers = [
    {
      name = "tictactoe";
      ensurePermissions = {
        "DATABASE tictactoe" = "ALL PRIVILEGES";
      };
    }
  ];
  systemd.services.tictactoe-server = {
    wantedBy = [ "multi-user.target" ];
    environment = {
      DATABASE_URL = "postgresql://tictactoe:tictactoe@localhost/tictactoe";
      PORT = "4000";
    };
    serviceConfig = {
      ExecStart = "${pkgs.tictactoe}/bin/tictactoe-server";
      DynamicUser = true;
      User = "tictactoe";
    };
  };
}
