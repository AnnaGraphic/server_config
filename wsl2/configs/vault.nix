{ lib, pkgs, ... }: {
  environment.systemPackages = [
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
      api_addr = "https://wsl2.m:8200"
      cluster_addr = "https://wsl2.m:8201"
    '';
    storageBackend = "raft";
    storageConfig = ''
      node_id = "raft_node_wsl2"
      retry_join {
        leader_api_addr = "https://spezi.m:8200"
      }
      retry_join {
        leader_api_addr = "https://kuno.m:8200"
      }
    '';
    tlsCertFile = "/etc/nixos/wsl2/certs/wsl2-vault-tls.crt";
    tlsKeyFile  = "/run/credentials/vault.service/tls.key";
  };

  systemd.services.vault.serviceConfig.LoadCredential = [
    "tls.key:/etc/panda/secrets/wsl2-vault-tls.key"
  ];

  # uncomment this to automatically restart vault.service after deployment
  #systemd.services.vault.serviceConfig.Restart = lib.mkForce "always";
}
