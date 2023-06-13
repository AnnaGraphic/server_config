{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
  inputs.disko.url = github:nix-community/disko;
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";
  
  outputs = { self, nixpkgs, disko, ... }@attrs: {
    nixosConfigurations.marika = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        ({modulesPath, ... }: {
          imports = [
            (modulesPath + "/installer/scan/not-detected.nix")
            (modulesPath + "/profiles/qemu-guest.nix")
            disko.nixosModules.disko
          ];
          disko.devices = import ./disk-config.nix;
          boot.loader.efi.efiSysMountPoint = "/boot";
          boot.loader.grub = {
            efiSupport = true;
            efiInstallAsRemovable = true;
            device = "nodev";
            copyKernel = false;
          };
          boot.initrd.kernelModules = [ "nvme" ];
          services.openssh.enable = true;
          networking.hostName = "marika";
          users.users.root.openssh.authorizedKeys.keys = [
            ''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCfP2xrEhEJn/MKTFbO6ATCqVr5jeqHqyRP9c4KKCA6eZDoZyovZQL6pM80b566rzpJGvLeRSlU10qYT+ftJBP/xhrRN4Jj5Xhp6phViSGz7uAb1uTWr93aO4r8XvNRzbjLreomsNQjyabrrEO+9K/fTQfwIfNxx52He3UTPg6Nq08FJOoqHarEFNRQqbgxr+Ad/wrXz8wZp7myUI5KrJppZ4t9VUElgfpPGHLt5jXPqdU0dfvBEvNCCX+QnBnNrIma2zwt/s4J+MizenpRWR37HU++qnIwh3hxOD3IgF/yX8nUZNbXeBBcGFR9VKDOPWYlCRz6LTDr4iai5+Qgc5mRhtZCfWzv0quzE9jPfhxjs9uHHGiHgbaLR8425d0x+XjZW1j6V1OZuwEUvEkgLxO9s6lZ1nklIjRPUNufeFTJ89VkVJd5iGIeQuBlyk2xXiNi0tMo8/JtNokPiwkYCNlMjvyRUm95DbZk+7mCqvNJHpMtPH46s3n0p0gzWYBI2q8= panda@spezi''
          ];
          system.stateVersion = "23.05";
        })
      ];
    };
  };
}
