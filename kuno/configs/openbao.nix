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
  services.openbao = {
    enable = true;
#    package = pkgs.writers.writeDashBin "vault" ''
#      exec ${pkgs.openbao}/bin/bao "$@"
#    '';

    settings = {
      api_addr = "https://kuno.m:8200";
      cluster_addr = "https://kuno.m:8201";

      storage = {
        raft = {
          path = "/var/lib/openbao";
          node_id = "raft_node_bao_kuno";
          retry_join = [
            {
              leader_api_addr = "https://spezi.m:8200";
              leader_client_cert_file = "/etc/nixos/kuno/certs/kuno-openbao-tls.crt";
              leader_client_key_file = "/run/credentials/openbao.service/tls.key";
            }
            {
              leader_api_addr = "https://wsl2.m:8201";
              leader_client_cert_file = "/etc/nixos/kuno/certs/kuno-openbao-tls.crt";
              leader_client_key_file = "/run/credentials/openbao.service/tls.key";
            }
          ];
        };
      };

      listener.default = {
          type = "tcp";
          address = "[::]:8200";
          tls_cert_file = "/etc/nixos/kuno/certs/kuno-openbao-tls.crt";
          tls_key_file  = "/run/credentials/openbao.service/tls.key";
      };
    };
  };
# TODO eigene Service config
  systemd.services.openbao.serviceConfig.LoadCredential = [
    "tls.key:/etc/panda/secrets/kuno-openbao-tls.key"
  ];
}
          #tls_key_file = "/etc/panda/secrets/kuno-openbao-tls.key";
