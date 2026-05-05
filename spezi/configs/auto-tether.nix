{ config, pkgs, ... }: {
  systemd.services."usb_tether@" = {
    serviceConfig = {
      SyslogIdentifier = "usb_tether";
      ExecStartPre = "${pkgs.android-tools}/bin/adb -s %i wait-for-device";
      ExecStart = "${pkgs.android-tools}/bin/adb -s %i shell svc usb setFunctions rndis";
    };
  };
  services.udev.extraRules = /* sh */ ''
    ACTION=="add", SUBSYSTEM=="net", KERNEL=="usb*", NAME="android"

    # idProduct==Pixel 5
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idProduct}=="4ee7", \
    TAG+="systemd", ENV{SYSTEMD_WANTS}+="usb_tether@$attr{serial}.service"
  '';
  systemd.network.networks.android = {
    matchConfig.Name = "android";
    DHCP = "yes";
  };
}

