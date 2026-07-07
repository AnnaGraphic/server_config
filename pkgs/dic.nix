{ lib, pkgs, stdenv }:

stdenv.mkDerivation {
  name = "dic";

  src = pkgs.fetchgit {
    url = "https://cgit.krebsco.de/dic";
    rev = "refs/tags/v1.1.2";
    hash = "sha256-pqzXgn+0rQ2EWXpslhibctpxHN+nMr/GMJMr3cmTBpw=";
  };

  phases = [
    "unpackPhase"
    "installPhase"
  ];

  installPhase =
    let
      path = lib.makeBinPath [
        pkgs.coreutils
        pkgs.curl
        pkgs.gnused
        pkgs.gnugrep
        pkgs.util-linux
      ];
    in
    ''
      mkdir -p $out/bin

      sed \
        's,^main() {$,&\n  PATH=${path}; export PATH,' \
        < ./dic \
        > $out/bin/dic

      chmod +x $out/bin/dic
    '';
}
