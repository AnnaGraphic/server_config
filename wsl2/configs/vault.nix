{ config, pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.vault
  ];

  environment.variables = {
    VAULT_ADDR = "http://127.0.0.1:8200";
  };

  networking.firewall.allowedTCPPorts = [
    8200
  ];

  services.vault = {
    enable = true;
    #dev = true;
    # enable authlistenerExtraConfig
    address = "0.0.0.0:8200";
    extraConfig = ''
      api_addr = "https://127.0.0.1:8200"
      cluster_addr = "https://127.0.0.1:8201"
      disable_mlock = true
    '';
    listenerExtraConfig = ''
      address = "0.0.0.0:8200"
      tls_disable = 1
    '';
    storageBackend = "raft";
  };
}

