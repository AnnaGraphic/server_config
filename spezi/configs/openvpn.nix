{ config, pkgs, ... }:

{
  services.openvpn.servers.c-base = {
    autoStart = true;

    config = ''
      client
      dev tun
      proto udp
      remote vpn.ext.c-base.org 1194

      resolv-retry infinite
      nobind
      persist-key
      persist-tun

      auth-user-pass /etc/panda/secrets/openvpn/c-base.auth

      verify-x509-name vpn.ext.c-base.org name
      ca /etc/panda/secrets/openvpn/ca.crt

      tls-auth /etc/panda/secrets/openvpn/ta.key 1

      comp-lzo
      script-security 2

      user nobody
      group nogroup
    '';
  };
}
