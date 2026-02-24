{ pkgs, ... }:
{
  boot.initrd = {
    availableKernelModules = [ "e1000e" ];
    extraUtilsCommands = ''
      copy_bin_and_libs ${pkgs.tor}/bin/tor
      copy_bin_and_libs ${pkgs.ntp}/bin/ntpdate
    '';
    network = {
      enable = true;
      udhcpc.enable = true;
      flushBeforeStage2 = true;
      postCommands = let
        torRc = pkgs.writeText "tor.rc" ''
          DataDirectory /etc/tor
          SOCKSPort 127.0.0.1:9050 IsolateDestAddr
          SOCKSPort 127.0.0.1:9063
          HiddenServiceDir /etc/tor/onion/bootup
          HiddenServicePort 22 127.0.0.1:22
        '';
      in ''
        echo "tor: preparing onion folder"
        chmod -R 700 /etc/tor

        echo "make sure localhost is up"
        ip addr add 127.0.0.1/8 dev lo
        ip link set lo up
        echo "ntp: starting ntpdate"
        echo "ntp   123/tcp" >> /etc/services
        echo "ntp   123/udp" >> /etc/services
        ntpdate 139.162.152.20 # pick one IP from https://www.ntppool.org/

        echo "tor: starting tor"
        tor -f ${torRc} &
      '';
      ssh = {
        enable = true;
        port = 22;
        authorizedKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDMe6DnF20BPefG3m9Naf/PdTJ/pjC1TTpsXtZQQ52We panda@spezi" ];
        hostKeys = [ "/home/panda/Sync/secrets/udo/udo-initrd-key" ];
      };
    };
    secrets."/etc/tor/onion/bootup" = "/etc/panda/secrets/boot/onion";
  };
}
