# manual stuff to be done in openbao
# - vault operator init
# - vault operator unseal
# - vault auth enable approle
# - define policies
# - link approle
# - get credentiels
# - adjust fw settings
# - tsl certs
# - check: path = "/var/lib/openbao" writable for service user
{ lib, pkgs, ... }: {
  environment.systemPackages = [
    # vault cli
    pkgs.openbao
  ];

  networking.firewall.allowedTCPPorts = [
    8200
    8201
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: lib.getName pkg == "vault";

#  systemd.services.vault.serviceConfig.ExecStart = lib.mkForce "${pkgs.openbao}/bin/openbao server ${configOptions}";
  services.vault = {
    enable = true;
    package = pkgs.writers.writeDashBin "vault" ''
      exec ${pkgs.openbao}/bin/bao "$@"
    '';

    # address = for extern Clients Vault-CLI, API
    address = "[::]:8200";
    extraConfig = ''
      api_addr = "https://kuno.m:8200"
      cluster_addr = "https://kuno.m:8201"
    '';

    storageBackend = "raft";
    storageConfig = ''
      path = "/var/lib/openbao"
      node_id = "raft_node_bao_kuno"

      retry_join {
        leader_api_addr = "https://spezi.m:8200"
      }

      retry_join {
        leader_api_addr = "https://wsl2.m:8201"
      }
    '';

    tlsCertFile = "/etc/nixos/kuno/certs/kuno-openbao-tls.crt"; # TODO SubjectAltName muss die jeweilige api_addr enthalten.
    tlsKeyFile  = "/run/credentials/vault.service/tls.key";
  };

# |TODO eigene Service config
  systemd.services.vault.serviceConfig.LoadCredential = [
    "tls.key:/etc/panda/secrets/kuno-openbao-tls.key"
  ];

  # uncomment this to automatically restart vault.service after deployment
  #systemd.services.vault.serviceConfig.Restart = lib.mkForce "always";
}
