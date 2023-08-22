# based on https://gist.github.com/misuzu/89fb064a2cc09c6a75dc9833bb3995bf
{ config, lib, pkgs, ... }@attrs: {
  imports = [
# this will work only under qemu, uncomment next line for full image
# <nixpkgs/nixos/modules/installer/netboot/netboot-minimal.nix>
    <nixpkgs/nixos/modules/installer/netboot/netboot.nix>
    <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
  ];

# stripped down version of https://github.com/cleverca22/nix-tests/tree/master/kexec
  system.build = {
    image = pkgs.runCommand "image" { buildInputs = [ pkgs.nukeReferences ]; } ''
      mkdir $out
      cp ${config.system.build.kernel}/bzImage $out/kernel
      cp ${config.system.build.netbootRamdisk}/initrd $out/initrd
      nuke-refs $out/kernel
      '';
    kexec_script = pkgs.writeTextFile {
      executable = true;
      name = "kexec-nixos";
      text = ''
#!${pkgs.stdenv.shell}
        set -efu
        ${pkgs.kexectools}/bin/kexec -l ${config.system.build.image}/kernel --initrd=${config.system.build.image}/initrd --append="init=${builtins.unsafeDiscardStringContext config.system.build.toplevel}/init ${toString config.boot.kernelParams}"
        sync
        echo "executing kernel, filesystems will be improperly umounted" >&2
        ${pkgs.kexectools}/bin/kexec -e
        '';
    };
    kexec_tarball = pkgs.callPackage <nixpkgs/nixos/lib/make-system-tarball.nix> {
      storeContents = [
      {
        object = config.system.build.kexec_script;
        symlink = "/kexec_nixos";
      }
      ];
      contents = [ ];
    };
  };

  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" ];
  boot.kernelParams = [
    "panic=30" "boot.panic_on_fail" # reboot the machine upon fatal boot issues
      "console=ttyS0" # enable serial console
      "console=tty1"
  ];
  boot.kernel.sysctl."vm.overcommit_memory" = "1";

  environment.systemPackages = [ pkgs.cryptsetup ];
  environment.variables.GC_INITIAL_HEAP_SIZE = "1M";

  networking.hostName = "kexec";

  services.getty.autologinUser = "root";

  services.openssh.enable = true;
  services.openssh.settings.KbdInteractiveAuthentication = false;
  services.openssh.settings.PasswordAuthentication = false;

  users.users.root.openssh.authorizedKeys.keys =
    (import ./config.nix attrs).users.users.root.openssh.authorizedKeys.keys;

  system.stateVersion = "23.05";
                                  }

