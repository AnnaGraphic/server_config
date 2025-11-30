{ config, ... }: let
  quirks.kuno.ipv4addr = "10.100.0.1";
  quirks.spezi.ipv4addr = "10.100.0.2";
  quirks.komplizin.ipv4addr = "10.100.0.3";
  quirks.wsl2.ipv4addr = "10.100.0.6";
  quirks.udo.ipv4addr = "10.100.0.8";

  cfg = quirks.${config.networking.hostName};
in {
  systemd.network.networks.wg0.linkConfig.MTUBytes = "1400";

  networking.extraHosts = ''
    10.100.0.1 kuno.w
    10.100.0.2 spezi.w
    10.100.0.3 komplizin.w
    10.100.0.4 prima.w
    10.100.0.6 wsl2.w
    ${quirks.udo.ipv4addr} udo.w
  '';

  networking.firewall.allowedUDPPorts = [
    config.networking.wireguard.interfaces.wg0.listenPort # 51820
  ];

  networking.interfaces.wg0.ipv4.routes =
    if config.networking.hostName == "kuno" then
      [
        {
          address = "10.100.0.0";
          prefixLength = 24;
        }
      ]
    else
      [];

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
          # prima
          {
            publicKey = "LzElUKPVvjC+fxoQ0URkkSiV058yvDqo2cUv7E129mU=";
            allowedIPs = [ "10.100.0.4/32" ];
          }
          # pixel5 a
          {
            publicKey = "Wn/MrINbn5/LeNq8U7dhgjVafbh2CNi0mMyunMMUsWo=";
            allowedIPs = [ "10.100.0.5/32" ];
          }
          # wsl2
          {
            publicKey = "J/kVPBEHpM9SSowGgwYUwDl5MuyNN6jGB3fA61BBhkQ=";
            allowedIPs = [ "10.100.0.6/32" ];
          }
          # pixel5 n
          {
            publicKey = "ZQUBpgcH0zIJBDKYL/l/tspkQYUnCV6jR2Ur+h0Kfgo=";
            allowedIPs = [ "10.100.0.7/32" ];
          }
          # udo
          {
            publicKey = "hea5esPrkydOB2DhQ8Y77LaNXwWkfZSsxDN9UEXor10=";
            allowedIPs = [ "${quirks.udo.ipv4addr}/32" ];
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
