{ pkgs, ... }: {
  services.nginx.enable = true;
  services.nginx.virtualHosts."textadventure.panda.krebsco.de" = {
    listen = [
      { addr = "0.0.0.0"; port = 80; }
    ];
    locations."/".root = "${pkgs.textadventure}/lib/client";
  };
}