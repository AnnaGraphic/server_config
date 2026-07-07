{
  nixpkgs.overlays = [(self: super: {
    dic = self.callPackage ../pkgs/dic.nix {};
    pi = self.callPackage ../pkgs/pi.nix {};
  })];
#  nixpkgs.config.packageOverrides = pkgs: {
#    pi = pkgs.callPackage ../pkgs/pi.nix {};
#  };
}
