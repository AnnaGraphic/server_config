{ lib ? pkgs.lib
, pkgs ? import <nixpkgs> {}
}:
let
  # Missing library functions.
  readJSON = path: builtins.fromJSON (builtins.readFile path);

  # To build a different version of tictactoe,
  # 1. change the rev attribute to the desired value
  # 2. replace the value of the hash attribute with an empty string
  # 3. try to build the package and let it fail to tell you the new hash
  # 4. insert the new hash value
  src = pkgs.fetchFromGitHub {
    owner = "AnnaGraphic";
    repo = "tictactoe";
    rev = "94b8a5622e87207d490b21a29f425187bffd8901";
    hash = "sha256-APq0AexY8TF78qHflyVMMxkGcVIMenJjHUQA44sDAg8=";
  };

  # Make contents of JSON files available in Nix.
  packageLock = readJSON (src + "/package-lock.json");
  clientProject = readJSON (src + "/apps/client/project.json");
  serverProject = readJSON (src + "/apps/server/project.json");

  # List of all (downloaded) tarballs mentioned in package-lock.json for
  # consumption by npm during the build where there is no network access.
  tarballs =
    map (p: pkgs.fetchurl { url = p.resolved; hash = p.integrity; })
        (lib.attrValues (removeAttrs packageLock.packages [ "" ]));

  # The cacache portion of an npm cache is stored as a separate derivation to
  # prevent expensive rebuilds unless package-lock.json actually references a
  # new set of packages.  For details about the npm cache, see [npm-cache].
  #
  # [npm-cache]: https://docs.npmjs.com/cli/v9/commands/npm-cache
  cacache =
    pkgs.runCommand "tictactoe-cacache" {
      passAsFile = [ "tarballs" ];
      tarballs = lib.concatLines tarballs;
    } /* sh */ ''
      while read -r tarball; do
        echo "caching $tarball" >&2
        ${pkgs.nodejs}/bin/npm cache add --cache . "$tarball"
      done < "$tarballsPath"
      ${pkgs.coreutils}/bin/cp -r _cacache $out
    '';

  # Similarly to cacache above, store node_modules as separate derivation to
  # prevent unnecessary rebuilds unless cacache 
  node_modules =
    pkgs.stdenv.mkDerivation {
      name = "tictactoe-node_modules";
      src = pkgs.runCommand "tictactoe-node_modules-src" {} /* sh */ ''
        mkdir -p $out/.npm
        ln -s ${cacache} $out/.npm/_cacache
        ln -s ${src + "/package-lock.json"} $out/package-lock.json
      '';
      buildInputs = [ pkgs.nodejs ];
      outputs = [ "out" "dev" ];
      buildPhase = /* sh */ ''
        # Tell npm where to find ~/.npm
        export HOME=$PWD

        # Create node_modules suitable for build time.
        npm ci --ignore-scripts
        mv node_modules $dev

        # Create smaller node_modules suitable for run time.
        npm ci --ignore-scripts --omit=dev
        mv node_modules $out
      '';
    };
in
pkgs.stdenv.mkDerivation {
  pname = packageLock.name;
  version = packageLock.version;

  inherit src;

  buildInputs = [
    pkgs.nodejs
  ];

  buildPhase = /* sh */ ''
    # If src points to a local git checkout that was used for development,
    # there might be a node_modules that has to be removed for this build.
    rm -fR node_modules

    # Install node_modules suitable for building.
    cp -r ${node_modules.dev} node_modules

    # Allow nx to write to node_modules/.cache
    chmod -R +w node_modules

    nx run client:build
    nx run server:build
  '';

  installPhase = /* sh */ ''
    mkdir $out

    mkdir $out/lib
    ln -s ${node_modules} $out/lib/node_modules
    cp -a ${clientProject.targets.build.options.outputPath} $out/lib/client
    cp -a ${serverProject.targets.build.options.outputPath} $out/lib/server
    cp -a apps/sql $out/lib/sql

    mkdir $out/bin

    cat > $out/bin/tictactoe-server <<\EOF
    #! ${pkgs.dash}/bin/dash
    # usage: DATABASE_URL=postgresql:... PORT=4000 tictactoe-server

    set -efu
    out=${placeholder "out"}

    ${pkgs.postgresql}/bin/psql -d "$DATABASE_URL" < $out/lib/sql/setup.sql

    export NODE_PATH=$out/lib/node_modules
    exec ${pkgs.nodejs}/bin/node $out/lib/server/main.js "$@"
    EOF

    chmod -R +x $out/bin
  '';
}
