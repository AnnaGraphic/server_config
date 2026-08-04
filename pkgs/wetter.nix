{ lib, pkgs }:

let
  src = pkgs.fetchFromGitHub {
    owner = "4z3";
    repo = "wetter";
    rev = "1.0.1";
    hash = "sha256-CZGTsgX1FZmfQ7Ix9SpQIsxl6j5wnIAvwUJ6vkIKaSA=";
  };
in

pkgs.runCommand "wetter-1.0.1" {
} /* sh */ ''
  ${pkgs.coreutils}/bin/mkdir -p $out/bin
  ${pkgs.gnused}/bin/sed \
      's@^#!buildShellBin .*@export PATH=${lib.makeBinPath [
        pkgs.attr
        pkgs.coreutils
        pkgs.curl
        pkgs.gawk
        pkgs.gnuplot
        pkgs.gnused
        pkgs.jq
      ]}@' \
      < ${src}/wetter \
      > $out/bin/wetter
  ${pkgs.coreutils}/bin/chmod +x $out/bin/wetter
''
