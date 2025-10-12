# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ../configs/wireguard.nix
      ./hardware-configuration.nix
      ./configs/mycelium.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  # boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only
  
  networking.extraHosts = builtins.readFile /etc/panda/hosts;
  networking.hostName = "komplizin"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  nix.gc.automatic = true;
  nix.gc.dates = "monthly";
  nix.gc.options = "--delete-older-than 30d";

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  services.logind.extraConfig = ''
    HandleHibernateKey=ignore
    HandlePowerKey=ignore
    HandleSuspendKey=ignore
  '';

  # because extraConfig is not extra enough:
  services.logind.lidSwitch = "ignore";
  services.logind.lidSwitchDocked = "ignore";
  services.logind.lidSwitchExternalPower = "ignore";

  # Enable the X11 windowing system.
  services.xserver.enable = false;


  services.xserver.desktopManager.plasma6.enable = true;
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "panda";
  services.xserver.layout = "us";
  services.xserver.xkbVariant = "altgr-intl";
  

  # Configure keymap in X11
  services.xserver.xkb.layout = "us";
  services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  hardware.pulseaudio.enable = false;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  users.users.root = {
    hashedPassword = "$6$H3FjVbsUn1ghFdzU$n1pP.ZsE8YP6uwKvkfvI/9eCyEWD.URa7GuOoLRmYUpLH8kkAje2LsattuyKCs6.Z4usoGBLcn/opjb7hbBC4/";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCfP2xrEhEJn/MKTFbO6ATCqVr5jeqHqyRP9c4KKCA6eZDoZyovZQL6pM80b566rzpJGvLeRSlU10qYT+ftJBP/xhrRN4Jj5Xhp6phViSGz7uAb1uTWr93aO4r8XvNRzbjLreomsNQjyabrrEO+9K/fTQfwIfNxx52He3UTPg6Nq08FJOoqHarEFNRQqbgxr+Ad/wrXz8wZp7myUI5KrJppZ4t9VUElgfpPGHLt5jXPqdU0dfvBEvNCCX+QnBnNrIma2zwt/s4J+MizenpRWR37HU++qnIwh3hxOD3IgF/yX8nUZNbXeBBcGFR9VKDOPWYlCRz6LTDr4iai5+Qgc5mRhtZCfWzv0quzE9jPfhxjs9uHHGiHgbaLR8425d0x+XjZW1j6V1OZuwEUvEkgLxO9s6lZ1nklIjRPUNufeFTJ89VkVJd5iGIeQuBlyk2xXiNi0tMo8/JtNokPiwkYCNlMjvyRUm95DbZk+7mCqvNJHpMtPH46s3n0p0gzWYBI2q8= panda@spezi"
    ];
  };
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.panda = {
    isNormalUser = true;
    hashedPasswordFile = "/etc/panda/secrets/panda.hashedPassword";
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = [
     pkgs.alacritty
     pkgs.brave
     pkgs.firefox-devedition
     pkgs.libreoffice-qt
     pkgs.vlc
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = [
    pkgs.borgbackup
    (pkgs.vim-full.customize {
      name = "vim";
      vimrcConfig.customRC = ''
        set backspace=indent,eol,start
        set expandtab
        set nocompatible
        set shiftwidth=2
        set smartindent
        set softtabstop=2
        set tabstop=2
        syntax on
      '';
  })
  # vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    pkgs.wget
    pkgs.git
    pkgs.weechat
    pkgs.mosh
  ];
  environment.variables = {
    "EDITOR" = "vim";
  };
  
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true; # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?

}

