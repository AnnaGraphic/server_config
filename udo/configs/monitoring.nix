{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.influxdb2-cli
  ];
  # manual steps: set pwd in web ui on first login
  #  add influxDB as data source (url, org, bucket, token)
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
        root_url = "http://localhost:3000/";
      };
    };
  };
  services.influxdb2 = {
    enable = true;
    settings = {
      http-bind-address = "127.0.0.1:8086";
    };
  };
}
