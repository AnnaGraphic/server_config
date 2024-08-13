{ pkgs, ... }: let
  nixpkgs-unstable-src = pkgs.fetchFromGitHub {
    owner = "NixOs";
    repo = "nixpkgs";
    rev = "58a1abdbae3217ca6b702f03d3b35125d88a2994";
    hash = "sha256-mdTQw2XlariysyScCv2tTE45QSU9v/ezLcHJ22f0Nxc=";
  };
  nixpkgs-unstable = import nixpkgs-unstable-src {};
in {
  services.mycelium = {
    enable = true;
    openFirewall = true;
    package = nixpkgs-unstable.mycelium;
  };
}
