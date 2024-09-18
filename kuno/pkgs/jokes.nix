{ lib ? pkgs.lib
, pkgs ? import <nixpkgs> {}
}:
let
  src = pkgs.fetchFromGitHub {
    owner = "AnnaGraphic";
    repo = "witzikon-api";
    rev = "5574c84dae585843d58ca3730eb5799d72a59079";
    hash = "sha256-QE13QFJkmOcYgpb3Xmr+ecSuOHb8JTLOUkZPQSdhVqw=";
  };

in
pkgs.stdenv.mkDerivation {
  name = "jokes";
  # for name vs. pname: https://github.com/NixOS/nixpkgs/blob/master/pkgs/stdenv/generic/make-derivation.nix
  #pname = "jokes";
  #version = "1.0.0";

  inherit src;

  installPhase = /* sh */ ''

    #find; ls -l; exit 1 # show all existing files and exit with error 1

    mkdir $out

    mkdir -p $out/lib/server

    cp -a server.ts $out/lib/server/main.ts

    mkdir $out/bin

    cat > $out/bin/jokes-server <<\EOF
    #! ${pkgs.dash}/bin/dash
    # usage: PORT=4001 jokes-server

    set -efu
    out=${placeholder "out"} # https://discourse.nixos.org/t/what-is-the-difference-between-placeholder-out-and-out/4862

    # TODO initialize mongodb with jokes database and collection

    exec ${pkgs.deno}/bin/deno run \
        --allow-env \
        --allow-net \
        $out/lib/server/main.ts
    EOF

    chmod -R +x $out/bin
  '';
}
