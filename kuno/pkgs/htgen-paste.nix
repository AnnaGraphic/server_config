{ fetchurl, lib, pkgs, stdenv }:
stdenv.mkDerivation rec {
  pname = "htgen-paste";
  version = "1.0.0";

  src = fetchurl {
    url = "https://cgit.krebsco.de/stockholm/plain/krebs/5pkgs/simple/htgen-paste/src/htgen-paste?id=363b381eeca12c54c83b4841198d189d470d345e";
    sha256 = "1xrj4cv365kh9ydja1vawxawzpc0f0mb440n0c3gjvd2s0yzykwq";
  };

  unpackPhase = ":";

  buildPhase = ''
    (
      exec > htgen-paste
      echo PATH=${lib.makeBinPath [
        pkgs.nix
        pkgs.file
        pkgs.coreutils
        pkgs.findutils
      ]}
      echo STATEDIR=${lib.escapeShellArg "\${STATEDIR-$HOME}"}
      cat $src
    )
  '';

  installPhase = ''
    install -D htgen-paste $out/bin/htgen-paste
  '';
}
