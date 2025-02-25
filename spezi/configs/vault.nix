{ lib, pkgs, ... }: {
  environment.systemPackages = [
    # vault cli
    pkgs.vault
  ];

  networking.firewall.allowedTCPPorts = [
    8200
    8201
  ];

  services.vault = {
    enable = true;
    address = "[::]:8200";
    extraConfig = ''
      api_addr = "https://spezi.m:8200"
      cluster_addr = "https://spezi.m:8201"
    '';
    storageBackend = "raft";
    storageConfig = ''
      node_id = "raft_node_spezi"
      retry_join {
        leader_api_addr = "https://wsl2.m:8200"
      }
      retry_join {
        leader_api_addr = "https://kuno.m:8200"
      }
    '';
    tlsCertFile = "/etc/nixos/spezi/certs/spezi-vault-tls.crt";
    tlsKeyFile  = "/run/credentials/vault.service/tls.key";
  };

  systemd.services.vault.serviceConfig.LoadCredential = [
    "tls.key:/etc/panda/secrets/spezi-vault-tls.key"
  ];
  # uncomment this to automatically restart vault.service after deployment
  #systemd.services.vault.serviceConfig.Restart = lib.mkForce "always";
}
