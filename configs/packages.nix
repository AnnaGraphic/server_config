{
  nixpkgs.overlays = [(self: super: {
    pi = self.callPackage ../pkgs/pi.nix {};
  })];
#  nixpkgs.config.packageOverrides = pkgs: {
#    pi = pkgs.callPackage ../pkgs/pi.nix {};
#  };
}
