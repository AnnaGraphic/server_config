{ config, pkgs, ... }:
{ 
  networking.networkmanager = {
    enable = true;

    plugins = with pkgs; [
      networkmanager-openvpn
    ];

    ensureProfiles.profiles."c-base" = {
      connection = {
        id = "vpn.ext.c-base.org";
        type = "vpn";
      };

      vpn = {
        service-type = "org.freedesktop.NetworkManager.openvpn";

        connection-type = "password";

        remote = "vpn.ext.c-base.org:1194";
        proto = "udp";

        dev = "tun";
        dev-type = "tun";

        ca = "/etc/panda/secrets/openvpn/ca.crt";

        ta = "/etc/panda/secrets/openvpn/ta.key";
        ta-dir = "1";

        comp-lzo = "adaptive";

        verify-x509-name = "name:vpn.ext.c-base.org";

        username = "panda";
      };
    };
  };
}
