{ lib ? pkgs.lib
, pkgs ? import <nixpkgs> {}
}:
let
  # To build a different version of textadventure,
  # 1. change the rev attribute to the desired value
  # 2. replace the value of the hash attribute with an empty string
  # 3. try to build the package and let it fail to tell you the new hash
  # 4. insert the new hash value
  src = pkgs.fetchFromGitHub {
    owner = "AnnaGraphic";
    repo = "textadventure-mitte";
    rev = "6008689ad4ae8e5bf65d0e0b360e4905f160d659";
    hash = "sha256-cO04ZUrDLqdm1mA/rl5qHGvpCqvPLMZdH4DoEjy8Mzw=";
  };
in
pkgs.stdenv.mkDerivation {
  pname = "textadventure";
  version = "0.0.0";

  inherit src;

  installPhase = /* sh */ ''
    mkdir $out

    mkdir $out/lib
    cp -a public $out/lib/client
  '';
}
