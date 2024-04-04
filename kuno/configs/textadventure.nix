{ pkgs, ... }: {
  services.nginx.enable = true;
  services.nginx.virtualHosts."wohnungssuche.die-partei-berlin.de" = {
    locations."/".root = "${pkgs.textadventure}/lib/client";
  };
}