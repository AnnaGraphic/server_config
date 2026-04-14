{
  boot.enableContainers = true;
  virtualisation.containers.enable = true;

  networking.nat = {
    enable = true;
    enableIPv6 = true;
  };

  networking.firewall.extraCommands = ''
    iptables -t nat -A POSTROUTING \
      -s 192.168.100.0/24 ! -d 192.168.100.0/24 \
      -j MASQUERADE
  '';

  networking.firewall.extraStopCommands = ''
    iptables -t nat -D POSTROUTING \
      -s 192.168.100.0/24 ! -d 192.168.100.0/24 \
      -j MASQUERADE || true
  '';

  containers.pi-agent = {
    autoStart = true;
    privateNetwork = true;

    hostAddress = "192.168.100.20";
    localAddress = "192.168.100.21";

    config = { config, pkgs, lib, ... }: {

      imports = [
        ../configs/packages.nix
      ];

      networking = {
        useHostResolvConf = lib.mkForce false;
      };

      services.resolved.enable = true;

      # create a dedicated unprivileged user
      users.users.pi = {
        isSystemUser = true;
        group = "pi";
        home = "/var/lib/pi-agent";
        createHome = true;
      };
      users.groups.pi = {};

      # example runtime (adjust depending on Pi requirements)
      environment.systemPackages = with pkgs; [
        coreutils
        git
        nodejs
        python3
      ];

      systemd.services.pi-agent = {
        description = "Pi Coding Agent";
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          ExecStart = "${pkgs.bash}/bin/bash -lc 'exec ${pkgs.coreutils}/bin/tail -f /dev/null | exec ${pkgs.pi}/bin/pi --mode rpc --verbose'";
          Restart = "on-failure";
          RestartSec = "5s";
          User = "pi";
          StateDirectory = "pi-agent";
          WorkingDirectory = "/var/lib/pi-agent";
          StandardOutput = "journal";
          StandardError = "journal";

          # security hardening
          NoNewPrivileges = true;
          PrivateTmp = true;
          ProtectSystem = "strict";
          ProtectHome = true;
        };

        environment = {
          HOME = "/var/lib/pi-agent";
          PI_CODING_AGENT_DIR = "/var/lib/pi-agent/.pi/agent";
          OPENAI_API_KEY = "your-key-here"; # better: load from file (see below)
        };
      };

      system.stateVersion = "25.11";
    };
  };
}
