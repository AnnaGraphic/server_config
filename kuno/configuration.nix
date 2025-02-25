{ config, modulesPath, pkgs, ... }: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ../configs/wireguard.nix
    ./configs/jokes.nix
    ./configs/mycelium.nix
    ./configs/nameserver.nix
    ./configs/nginx.nix
    ./configs/paste.nix
    ./configs/portfolio-panda.nix
    ./configs/textadventure.nix
    ./configs/tictactoe.nix
    ./configs/vault.nix
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

  security.pki.certificateFiles = [
    ../certs/panda-root-ca-2025-1.crt
  ];

  services.postgresql = {
    authentication = ''
      host all all all password
    '';
    enable = true;
    enableTCPIP = true;
    ensureDatabases = [
      "socialnetwork"
    ];
    ensureUsers = [{
      name = "socialnetwork";
      ensureDBOwnership = true; # ownership only via SQL commands
    }];
  };

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

  networking.firewall.allowedTCPPorts = [
    443  # https
  ];
  networking.firewall.interfaces.wg0.allowedTCPPorts = [ 5432 ];

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
    hashedPasswordFile = "/etc/panda/secrets/panda.hashedPassword";
    packages = [
      pkgs.tmux
      pkgs.weechat
    ];
  };

  users.users.prima = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      # for reverse ssh tunnel from prima (see prima@prima:tunnelfummel)
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINDzjDjfvD9dWthQItx6iWlezgxPVSJCylpMiQVymRU3"
    ];
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCfP2xrEhEJn/MKTFbO6ATCqVr5jeqHqyRP9c4KKCA6eZDoZyovZQL6pM80b566rzpJGvLeRSlU10qYT+ftJBP/xhrRN4Jj5Xhp6phViSGz7uAb1uTWr93aO4r8XvNRzbjLreomsNQjyabrrEO+9K/fTQfwIfNxx52He3UTPg6Nq08FJOoqHarEFNRQqbgxr+Ad/wrXz8wZp7myUI5KrJppZ4t9VUElgfpPGHLt5jXPqdU0dfvBEvNCCX+QnBnNrIma2zwt/s4J+MizenpRWR37HU++qnIwh3hxOD3IgF/yX8nUZNbXeBBcGFR9VKDOPWYlCRz6LTDr4iai5+Qgc5mRhtZCfWzv0quzE9jPfhxjs9uHHGiHgbaLR8425d0x+XjZW1j6V1OZuwEUvEkgLxO9s6lZ1nklIjRPUNufeFTJ89VkVJd5iGIeQuBlyk2xXiNi0tMo8/JtNokPiwkYCNlMjvyRUm95DbZk+7mCqvNJHpMtPH46s3n0p0gzWYBI2q8= panda@spezi"
  ];

  system.stateVersion = "23.05";
}
