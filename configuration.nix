# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(4) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./shell.c-base.org.nix
      ./dic.nix
      ./wetter.nix
      ./configs/alacritty.nix
      ./configs/mycelium.nix
     # ./modules/mycelium.nix
     # ./openvpn/c-base/default.nix
    ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # to allow unfree packages like lutris
  nixpkgs.config.allowUnfree = true;

  nix.optimise.automatic = true;

  # enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.extraHosts = builtins.readFile /home/panda/Sync/hosts;
  networking.hostName = "spezi"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
   # keyMap = "us";
     useXkbConfig = true; # use xkbOptions in tty.
   };

  services.borgbackup.jobs.spezi-home-panda-backup_komplizin = {
    paths = "/home";
    encryption.mode = "none";
    environment.BORG_RSH = "ssh -i /home/panda/.ssh/id_rsa -o UserKnownHostsFile=/home/panda/.ssh/known_hosts";
    exclude = [
      "/home/*/tmp"
      "/home/*/.cache"
      "/home/*/.vscode-oss"
      "/home/*/.npm"
      "/home/*/.mozilla"
      "/home/*/VirtualBox VMs"
      "/home/*/Downloads"
      "/home/*/projekte/*/node_modules"
      "/home/*/.local"
      "/home/*/.steam"
    ];
    repo = "ssh://root@komplizin.m:22/backups/spezi-home-panda-backup_komplizin";
    compression = "auto,zstd";
    startAt = "*-*-* 04:00:00";
  };

  #  mount storage box
  services.davfs2.enable = true;

  services.ferretdb.enable = true;

  # konfiguriert in KDE Energy Savings
  services.logind = {
    # extraConfig = ''HandlePowerKey=ignore'';
    lidSwitch = "ignore";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "ignore";
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [
      "panda"
      "tictactoe"
      "memory1312"
    ];
    ensureUsers = [{
      name = "panda";
      ensureDBOwnership = true; # ownership only via SQL commands
    }];
  };

#  services.udev.extraRules = /* udev */ ''
#    SUBSYSTEM=="tty", ACTION=="add", ENV{ID_MODEL}=="flow3r", \
#    SYMLINK+="flow3r", GROUP="wheel", \
#    RUN+="${pkgs.writers.writeDash "piep" ''
#      set -efu
#      /run/wrappers/bin/sudo \
#          -u panda \
#          ${pkgs.coreutils}/bin/env \
#              DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
#              ${pkgs.libnotify}/bin/notify-send "flow3r im flash mode"
#    ''}"
#  '';

  services.wordpress.sites."localhost" = {};

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "panda";
  services.xserver.layout = "us";
  services.xserver.xkbVariant = "altgr-intl";
  services.syncthing = {
    enable = true;
    user = "panda";
    dataDir = "/home/panda/";
    configDir = "/home/panda/.config/syncthing";
  };

  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
      enable = true;
        setSocketVariable = true;
  };

  # VM-Sachen
  virtualisation.virtualbox.host.enable = true;
  #virtualisation.restrictNetwork = false;

  # tells from where to boot after hibernating
  boot.kernelParams = [
    "resume=UUID=58e8971d-2a81-424c-8fb0-4ade8c67964b"
];

  # desktop settings
  programs.dconf.enable = true;

  # Configure keymap in X11
  services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # Enable direct rendering
  hardware.opengl.driSupport32Bit = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Allow panda's VMs to access USB devices
  users.extraGroups.docker.members = [ "panda" ];
  users.extraGroups.vboxusers.members = [ "panda" ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.root = {
    hashedPasswordFile = "/etc/secrets/nixospandapassword";
  };
  users.users.panda = {
    isNormalUser = true;
    hashedPasswordFile = "/etc/secrets/nixospandapassword";
    extraGroups = [
      "adbusers"
      "audio"
      "networkmanager"
      "vboxusers"
      "video"
      "wheel"  # Enable ‘sudo’ for the user.
    ];

    packages = [
      pkgs.alacritty-panda # use alacritty wrapper defined in configs/alacritty.nix
      pkgs.brave
      pkgs.firefox
      pkgs.firefox-devedition
      pkgs.joplin
      pkgs.libreoffice-qt
      pkgs.lutris
      pkgs.vlc
      (pkgs.vscode-with-extensions.override {
        vscode = pkgs.vscodium;
        vscodeExtensions = [
          pkgs.vscode-extensions.github.copilot
          pkgs.vscode-extensions.github.copilot-chat
          pkgs.vscode-extensions.vscodevim.vim
        ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "LiveServer";
            publisher = "ritwickdey";
            version = "5.6.1";
            sha256 = "sha256-QPMZMttYV+dQfWTniA7nko7kXukqU9g6Wj5YDYfL6hw";
          }
         ];
      })
    ];
  };

  environment.homeBinInPath = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = [
    (pkgs.writers.writeDashBin "storagebox" ''
      #! /usr/bin/env nix-shell
      #! nix-shell -i bash -p ''${pkgs.sshfs}/bin/sshfs
      # usage: storagebox
      set -x
      sshfs u267156@u267156.your-storagebox.de: /home/panda/storagebox/
    '')
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
        set undodir=$HOME/.cache/vim/undo
        set undofile
        set undolevels=10000
        syntax on
      '';
      vimrcConfig.packages.myVimPackage.start = [
        pkgs.vimPlugins.undotree
      ];
    })
    pkgs.davfs2 # mount storage-box via webDav
    pkgs.wget
    pkgs.git
    pkgs.weechat
    pkgs.mosh # mobile shell
    pkgs.libsForQt5.ark
    pkgs.posix_man_pages
    pkgs.virtualboxWithExtpack
    # filemanager config under ~/.config/ranger
    pkgs.ranger
    pkgs.sxiv
  ];
  environment.variables = {
    "EDITOR" = "vim";
  }
;
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  programs.bash = {
    interactiveShellInit = /* sh */ ''
      HISTCONTROL='erasedups:ignorespace'
      HISTSIZE=900001
      HISTFILESIZE=$HISTSIZE
    '';
  };

  fonts.packages = [
    pkgs.jetbrains-mono
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  # services.tlp.enable = true; # for bluethooth etc # conflicts with services.power-profiles-demon

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?


}

