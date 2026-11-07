{ config, pkgs, lib, ... }:

let
  llmAgents = builtins.getFlake "github:numtide/llm-agents.nix";
  opencode2 = llmAgents.packages.x86_64-linux.opencode2;
in

{
  networking.nat = {
    enable = true;
    internalInterfaces = [ "ve-+" ];
    externalInterface = "wlp3s0";
  };

  boot.enableContainers = true;

  containers.opencode = {
    autoStart = true;
    privateNetwork = true;

    hostAddress = "192.168.101.20";
    localAddress = "192.168.101.21";

    config = { config, pkgs, lib, ... }: {

      networking = {
        useHostResolvConf = lib.mkForce false;
        firewall.allowedTCPPorts = [ 4096 ];
      };

      services.resolved.enable = true;

      users.groups.opencode = {};

      users.users.opencode = {
        isSystemUser = true;
        group = "opencode";
        home = "/var/lib/opencode";
        createHome = true;
      };

      environment.systemPackages = [
        opencode2
        pkgs.coreutils
        pkgs.git
        pkgs.nodejs
        pkgs.python3
      ];

      systemd.services.opencode = {
        description = "OpenCode Server";
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];

        serviceConfig = {
          ExecStart = ''
            ${pkgs.opencode}/bin/opencode serve \
              --hostname 0.0.0.0 \
              --port 4096
          '';

          Restart = "on-failure";
          RestartSec = "5s";

          User = "opencode";
          Group = "opencode";

          StateDirectory = "opencode";
          WorkingDirectory = "/";

          Environment = [
            "HOME=/tmp"
            "XDG_DATA_HOME=/tmp/.local/share"
            "XDG_CONFIG_HOME=/tmp/.config"
          ];
        
          StandardOutput = "journal";
          StandardError = "journal";

          NoNewPrivileges = true;
          PrivateTmp = true;
          ProtectSystem = "strict";
          ProtectHome = true;
          ReadWritePaths = [];
        };
      };

      system.stateVersion = "26.05";
    };
  };
}
