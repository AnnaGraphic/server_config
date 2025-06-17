{ pkgs, ... }: {
  services.uptime-kuma.enable = true;
  services.nginx.enable = true;
  services.nginx.virtualHosts."kuno.panda.krebsco.de" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:3001";
      proxyWebsockets = true;
    };
  };
  systemd.services.disk-root-check = {
    wantedBy = [ "multi-user.target" ];
    path = [
      pkgs.coreutils
      pkgs.curl
      pkgs.gawk
    ];
    serviceConfig = {
      ExecStart = pkgs.writers.writeDash "disk-root-check" ''
        set -eu

        TOKEN=$(cat /etc/panda/secrets/kuma-token-disk-root)
        USED=$(df -h / | awk 'NR==2 {print $(NF-1)}' | tr -d '%')

        if [ "$USED" -lt 90 ]; then
          curl -fsS "https://kuno.panda.krebsco.de/api/push/$TOKEN?status=up&msg=OK&ping=/"
        fi
      '';
    };
  };
  systemd.timers.disk-root-check = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* *:*:00/5";
      Persistent = true;
    };
  };
}
