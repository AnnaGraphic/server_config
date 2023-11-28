{ lib ? pkgs.lib
, pkgs ? import <nixpkgs> {}
}:
let
  # TODO mach ein jokes repo und siehe pkgs/tictactoe.nix wie das hier rein soll
  #       und dann kann ./jokes-source auch weg oder so
  src = ./jokes-source;
in
pkgs.stdenv.mkDerivation {
  name = "jokes";

  inherit src;

  installPhase = /* sh */ ''
    mkdir $out

    mkdir $out/lib
    cp -a server $out/lib/server

    mkdir $out/bin

    cat > $out/bin/jokes-server <<\EOF
    #! ${pkgs.dash}/bin/dash
    # usage: PORT=4001 jokes-server

    set -efu
    out=${placeholder "out"}

    # TODO initialize mongodb with jokes database and collection

    exec ${pkgs.deno}/bin/deno run \
        --allow-env \
        --allow-net \
        $out/lib/server/main.ts
    EOF

    chmod -R +x $out/bin
  '';
}
