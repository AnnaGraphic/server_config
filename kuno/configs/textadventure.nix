{ pkgs, ... }: {
  services.nginx.enable = true;
  services.nginx.virtualHosts."textadventure.panda.krebsco.de" = {
    locations."/".root = "${pkgs.textadventure}/lib/client";
  };
}