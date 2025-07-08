# manual stuff to be done in uptime kuma's web interface:
# - get push token via ptime kuma's web interface
# - configure kuno-disk-root: add monitor type push
# - configure wohnungssuche: add monitor type https
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
  # disk root check
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
      OnCalendar = "*-*-* *:*:00/2";
      Persistent = true;
    };
  };
  # check cpu usage
    systemd.services.check-cpu-usage = {
    wantedBy = [ "multi-user.target" ];
    path = [
      pkgs.coreutils
      pkgs.curl
      pkgs.gawk
    ];
    serviceConfig = {
      ExecStart = pkgs.writers.writeDash "check-cpu-usage" ''
      set -eu

      TOKEN=$(cat /etc/panda/secrets/kuma-token-cpu-load)
      PUSH_URL="https://kuno.panda.krebsco.de/api/push/$TOKEN"

      # get average cpu load of the last 1 minute
      LOAD=$(awk '{print $1}' /proc/loadavg)
      CPU_CORES=$(nproc)

      # get load in %
      LOAD_PCT=$(echo "$LOAD $CPU_CORES" | awk '{ printf "%.0f", ($1 / $2) * 100 }')

      echo check-cpu-usage $LOAD_PCT%

      if [ "$LOAD_PCT" -lt 85 ]; then
        # TODO log LOAD_PCT
        curl -fsS "$PUSH_URL?status=up&msg=CPU%20$LOAD_PCT%&ping=CPU"
      else
        curl -fsS "$PUSH_URL?status=down&msg=HIGH%20CPU%20$LOAD_PCT%&ping=CPU"
      fi
      '';
    };
  };
  systemd.timers.check-cpu-usage = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* *:*:00/2";
      Persistent = true;
    };
  };
}
