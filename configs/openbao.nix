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
{ config, lib, pkgs, ... }:

let

  host = config.networking.hostName;

  ports = {
    api = 8200;
    cluster = 8201;
  };

  baseCertDir = "/etc/nixos";
  baseSecretDir = "/etc/panda/secrets";

  hostNames = [ "komplizin" "kuno" "wsl2" ];

  mkHost = name: {
    apiAddr = "https://${name}.m:${toString ports.api}";
    clusterAddr = "https://${name}.m:${toString ports.cluster}";
    nodeId = "raft_node_bao_${name}";
    certPath = "${baseCertDir}/${name}/certs/${name}-openbao-tls.crt";
    keyCred = "tls.key:${baseSecretDir}/${name}-openbao-tls.key";
  };

  hosts = lib.genAttrs hostNames mkHost;

  # alle Peers außer dem aktuelle Host
  peers = lib.filterAttrs (name: _: name != host) hosts;

  retryJoin = lib.mapAttrsToList
    (name: h: {
      leader_api_addr = h.apiAddr;
      leader_client_cert_file = hosts.${host}.certPath;
      leader_client_key_file = "/run/credentials/openbao.service/tls.key";
    })
    peers;

in {
  environment.systemPackages = [
    # bao cli
    pkgs.openbao
  ];

  networking.firewall.allowedTCPPorts = [
    8200
    8201
  ];

  services.openbao = {
    enable = true;

    settings = {
      api_addr = hosts.${host}.apiAddr;
      cluster_addr = hosts.${host}.clusterAddr;

      storage.raft = {
        path = "/var/lib/openbao";
        node_id = hosts.${host}.nodeId;
        retry_join = retryJoin;
      };

      listener.default = {
          type = "tcp";
          address = "[::]:${toString ports.api}";
          tls_cert_file = hosts.${host}.certPath;
          tls_key_file  = "/run/credentials/openbao.service/tls.key";
      };
    };
  };
# TODO eigene Service config
  systemd.services.openbao.serviceConfig.LoadCredential = [
    hosts.${host}.keyCred
  ];
}
