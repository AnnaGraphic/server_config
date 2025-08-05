{ pkgs, ... }: {
  services.nginx.enable = true;
  services.nginx.virtualHosts."testsite.panda.krebsco.de" = {

    root = "/srv/www";

    locations."/" = {
      index = "index.html";
#      basicAuth = { user = "password"; };
    };

    enableACME = true;
    addSSL = true;

    extraConfig = ''
      auth_basic "gib pwd";
      auth_basic_user_file /etc/panda/secrets/basic.auth;
    '';
  };
}
