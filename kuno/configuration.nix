{ modulesPath, pkgs, ... }: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./configs/jokes.nix
    ./configs/nameserver.nix
    ./configs/nginx.nix
    ./configs/paste.nix
    ./configs/textadventure.nix
    ./configs/tictactoe.nix
    ./modules/htgen.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "kuno";

  boot.kernelParams = [
    "console=ttyS0"
    "console=tty1"
    "nvme.shutdown_timeout=10"
    "libiscsi.debug_libiscsi_eh=1"
    "net.ifnames=0"
  ];

  boot.initrd.kernelModules = [
    "nvme"
  ];

  environment.systemPackages = [
    (pkgs.vim_configurable.customize {
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
  ];

  networking.firewall.allowedTCPPorts = [ 443 ]; # https

  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;

  nixpkgs.overlays = [
    (import ./pkgs)
  ];

  programs.bash = {
    interactiveShellInit = /* sh */ ''
      HISTCONTROL='erasedups:ignorespace'
      HISTSIZE=900001
      HISTFILESIZE=$HISTSIZE
    '';
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/root";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "panda@c-base.org";

  services.openssh.enable = true;

  users.users.panda = {
    extraGroups = [
      "wheel"
    ];
    isNormalUser = true;
    hashedPasswordFile = "/etc/nixos/secrets/panda.hashedPassword";
    packages = [
      pkgs.tmux
      pkgs.weechat
    ];
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCfP2xrEhEJn/MKTFbO6ATCqVr5jeqHqyRP9c4KKCA6eZDoZyovZQL6pM80b566rzpJGvLeRSlU10qYT+ftJBP/xhrRN4Jj5Xhp6phViSGz7uAb1uTWr93aO4r8XvNRzbjLreomsNQjyabrrEO+9K/fTQfwIfNxx52He3UTPg6Nq08FJOoqHarEFNRQqbgxr+Ad/wrXz8wZp7myUI5KrJppZ4t9VUElgfpPGHLt5jXPqdU0dfvBEvNCCX+QnBnNrIma2zwt/s4J+MizenpRWR37HU++qnIwh3hxOD3IgF/yX8nUZNbXeBBcGFR9VKDOPWYlCRz6LTDr4iai5+Qgc5mRhtZCfWzv0quzE9jPfhxjs9uHHGiHgbaLR8425d0x+XjZW1j6V1OZuwEUvEkgLxO9s6lZ1nklIjRPUNufeFTJ89VkVJd5iGIeQuBlyk2xXiNi0tMo8/JtNokPiwkYCNlMjvyRUm95DbZk+7mCqvNJHpMtPH46s3n0p0gzWYBI2q8= panda@spezi"
  ];

  system.stateVersion = "23.05";
}
