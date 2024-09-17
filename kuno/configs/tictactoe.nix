{ pkgs, ... }: {
  networking.firewall.allowedTCPPorts = [
    80
    4000
  ];
  services.nginx.enable = true;
  services.nginx.virtualHosts."tictactoe.panda.krebsco.de" = {
    locations."/".root = "${pkgs.tictactoe}/lib/client";
    locations."/api".proxyPass = "http://127.0.0.1:4000";
  };
  services.postgresql.enable = true;
  services.postgresql.ensureDatabases = [
    "tictactoe"
  ];
  services.postgresql.ensureUsers = [
    {
      name = "tictactoe";
      ensureDBOwnership = true; # ownership only via SQL commands
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
