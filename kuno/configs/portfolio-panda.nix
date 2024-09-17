{ pkgs, ... }: {
  services.nginx.enable = true;
  services.nginx.virtualHosts."portfolio.panda.krebsco.de" = {
    locations."/".root = pkgs.portfolio-panda;
    enableACME = true;
    addSSL = true;
  };
}
