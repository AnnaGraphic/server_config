{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.influxdb2-cli
    pkgs.grafanactl
  ];
  # manual steps: set pwd in web ui on first login
  #  add influxDB as data source (url, org, bucket, token)
  services.grafana = {
    enable = true;
    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          #access = "direct";
          basicAuth	= false;
          editable = true;
          name = "influxdb";
          type = "influxdb";
          uid = "afeudgr1qd3b4f";
          url = "http://localhost:8086";
          jsonData = {
            httpMode = "POST";
            organization = "monitoring";
            #pdcInjected = false;
            version = "Flux";
          };
          secureJsonFields = {
          };
        }
      ];
    };
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
    provision = {
      enable = true;
      initialSetup = {
        organization = "monitoring";
        bucket = "a8";
        passwordFile = "/etc/panda/secrets/pandainfluxpassword";
        tokenFile = "/etc/panda/secrets/pandainfluxtoken";
      };
    };
    settings = {
      http-bind-address = "127.0.0.1:8086";
    };
  };
}
