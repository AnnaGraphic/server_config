{
  networking.firewall.allowedUDPPorts = [
    53 # domain
  ];

  services.knot = {
    enable = true;
    extraConfig = /* yaml */ ''
      server:
        listen: 10.0.0.197@53

      log:
        - target: syslog
          any: debug

      template:
        - id: default
          semantic-checks: on
          zonefile-sync: -1
          zonefile-load: difference-no-serial
          journal-content: all

      zone:
         - domain: panda.krebsco.de
           file: ${./panda.krebsco.de.zone}
    '';
  };
}
