{ config, lib, pkgs, ... }: {
  services.nginx.virtualHosts."paste.panda.krebsco.de" = {
    enableACME = true;
    addSSL = true;
    serverAliases = [ "paste.panda.krebsco.de" ];
    locations."/".extraConfig = ''
      proxy_set_header Host $host;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_pass http://127.0.0.1:${toString config.krebs.htgen.paste.port};
    '';
    locations."/form".extraConfig = ''
      client_max_body_size 4G;
      proxy_set_header Host $host;
      proxy_pass http://127.0.0.1:${toString config.krebs.htgen.paste-form.port};
    '';
    extraConfig = ''
      add_header 'Access-Control-Allow-Origin' '*';
      add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
    '';
  };

  krebs.htgen.paste = {
    port = 9081;
    scriptFile = "${pkgs.htgen-paste}/bin/htgen-paste";
  };

  krebs.htgen.paste-form = {
    port = 7770;
    script = /* sh */ ''
      export PATH=${lib.makeBinPath [
        pkgs.curl
        pkgs.gnused
      ]}:$PATH
      (. ${pkgs.writeScript "paste-form" ''
        case "$Method" in
          'POST')
            ref=$(head -c $req_content_length | sed '0,/^\r$/d;$d' | curl -fSs --data-binary @- https://paste.panda.krebsco.de | sed '1d;s/^http:/https:/')

            printf 'HTTP/1.1 200 OK\r\n'
            printf 'Content-Type: text/plain; charset=UTF-8\r\n'
            printf 'Server: %s\r\n' "$Server"
            printf 'Connection: close\r\n'
            printf 'Content-Length: %d\r\n' $(expr ''${#ref} + 1)
            printf '\r\n'
            printf '%s\n' "$ref"

            exit
          ;;
        esac
      ''})
    '';
  };

  systemd.services.paste-gc = {
    startAt = "daily";
    serviceConfig = {
      ExecStart = ''
        ${pkgs.findutils}/bin/find /var/lib/htgen-paste/items -type f -mtime +30 -exec rm {} +
      '';
      User = "htgen-paste";
    };
  };
}
