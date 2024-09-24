{ config, ... }: let
  quirks.kuno.ipv4addr = "10.100.0.1";
  quirks.spezi.ipv4addr = "10.100.0.2";
  quirks.komplizin.ipv4addr = "10.100.0.3";

  cfg = quirks.${config.networking.hostName};
in {
  networking.extraHosts = ''
    10.100.0.1 kuno.w
    10.100.0.2 spezi.w
    10.100.0.3 komplizin.w
  '';

  networking.firewall.allowedUDPPorts = [
    config.networking.wireguard.interfaces.wg0.listenPort # 51820
  ];

  networking.wireguard.interfaces.wg0 = {
    ips = [ "${cfg.ipv4addr}/24" ];
    allowedIPsAsRoutes = true;
    listenPort = 51820;
    privateKeyFile = "/etc/panda/secrets/wireguard-private-key";
    peers =
      if config.networking.hostName == "kuno" then
        [
          # spezi
          {
            publicKey = "ewHBJr8wLzCkZjfJVz5+wp0ZD/IeOibhGkmkJ8aqaQ0=";
            allowedIPs = [ "10.100.0.2/32" ];
          }
          # komplizin
          {
            publicKey = "n4nIrbchXj7cYVL8uPPH8dkO31Gi3pm8dvBx5BT0JH4=";
            allowedIPs = [ "10.100.0.3/32" ];
          }
        ]
      else
        [
          # kuno
          {
            publicKey = "5o4nO1O3pLDTCud1KiPh7eBElBgiyV1W5xOdh55S6lo=";
            allowedIPs = [ "10.100.0.0/24" ];
            endpoint = "kuno.panda.krebsco.de:51820";
            persistentKeepalive = 61;
          }
        ];
  };
}
