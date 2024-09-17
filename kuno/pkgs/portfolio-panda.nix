{ pkgs }:
pkgs.stdenv.mkDerivation {
  pname = "portfolio-panda";
  version = "1.0.0";

  # XXX src has to be rsynced in kuno's deploy script
  src = /etc/panda/portfolio;

  # XXX portfolio cannot be built by Nix because the theme it's using
  #     (https://blowfish.page/) requires internet access to fetch data from
  #     github API. therefore we assume that src already contains the built
  #     artifacts in its public directory
  #buildPhase = ''
  #  ${pkgs.hugo}/bin/hugo
  #'';

  installPhase = /* sh */ ''
    cp -a public $out
  '';
}
