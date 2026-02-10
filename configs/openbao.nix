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
# - generate hsm stuff:
#   openssl genpkey -algorithm RSA -out openbao.pem -pkeyopt rsa_keygen_bits:4096
#   # directrory: etc/secrets/<host>
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
    pkgs.opensc
    pkgs.softhsm
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

      seal.pkcs11 = {
        lib = "${pkgs.softhsm}/lib/softhsm/libsofthsm2.so";
        token_label = "OpenBao";
        pin = "6666";
        key_label = "bao-root-key-rsa";
        key_id = "0xd00f";
        rsa_oaep_hash = "sha1";
      };

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
    "openbao.pem:${baseSecretDir}/openbao.pem"
  ];

  systemd.services.openbao.preStart = ''
    set -efu

    token_directory=/var/lib/openbao/softhsm2/tokens
    root_key_file=/run/credentials/openbao.service/openbao.pem
    so_pin=77776666
    pin=6666
    key_id=A1BB

    ${pkgs.coreutils}/bin/rm -rf "$token_directory"
    ${pkgs.coreutils}/bin/mkdir -m 0700 -p "$token_directory"

    tmpfile=/tmp/softhsm2.p8

    ${pkgs.openssl}/bin/openssl pkcs8 -topk8 -inform PEM -outform PEM -nocrypt \
      -in "$root_key_file" -out "$tmpfile"

    ${pkgs.softhsm}/bin/softhsm2-util --init-token --slot 0 --label OpenBao \
      --so-pin "$so_pin" --pin "$pin"
    ${pkgs.softhsm}/bin/softhsm2-util --import "$tmpfile" --token OpenBao \
      --label bao-root-key-rsa --pin "$pin" --id "$key_id"

    ${pkgs.opensc}/bin/pkcs11-tool -v \
      --module ${pkgs.softhsm}/lib/softhsm/libsofthsm2.so -O -l -p "$pin"
  '';

  systemd.services.openbao.environment = {
    # TODO tokendir from variable
    SOFTHSM2_CONF = pkgs.writeText "softhsm2.conf" ''
      directories.tokendir = /var/lib/openbao/softhsm2/tokens
      log.level = INFO
      objectstore.backend = file
      slots.mechanisms = ALL
      slots.removable = false
    '';
  };
}
#{
#  systemd.services.openbao-configurator = {
#    partOf = [ "openbao.service" ];
#    script = ''
#      until kann-ich-openbao-api?; do sleep 1; done
#      mach-api-kram
#    '';
#    ServiceConfig = {
#      Type = "oneshot";
#    };
#  };
#}
