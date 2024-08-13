# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ config, lib, pkgs, ... }:

{
  imports = [
    # include NixOS-WSL modules
    <nixos-wsl/modules>
    ./configs/mycelium.nix
  ];

  #wsl.wslConf.automount.root = "/mnt"; # default true
  wsl = {
    enable = true;
    defaultUser = "nixos";
    # accessing windows paths can be as slow as 300x which is bad for auto completion
    interop.includePath = false;
    nativeSystemd = true;
    populateBin = lib.mkIf config.services.envfs.enable (lib.mkForce false);
    startMenuLaunchers = true;
    # rebuild less things
    useWindowsDriver = true;
    version.rev = lib.mkForce lib.fakeSha256;
    wslConf = {
      # see interop.includePath above
      interop.appendWindowsPath = false;
      network.generateResolvConf = !config.services.resolved.enable;
    };
  };

  environment.systemPackages = [
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
    pkgs.wget
    pkgs.git
  ];
  
  programs.java.enable = true;

# ab 24.05 
  programs.nix-ld = {
      enable = true;
      package = pkgs.nix-ld-rs;
  };
  
  # Enable OpenSSH daemon
  services.openssh.enable = true;

  users.extraGroups.docker.members = [ "nixos" ];
  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
      setSocketVariable = true;
  };
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
