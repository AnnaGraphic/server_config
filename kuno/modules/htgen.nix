{ config, lib, pkgs, ... }: let
  optionalAttr = name: value:
    if name != null then
      { ${name} = value; }
    else
      {};
in {
  options.krebs.htgen = lib.mkOption {
    default = {};
    type = lib.types.attrsOf (lib.types.submodule ({ config, ... }: {
      options = {
        enable = lib.mkEnableOption "krebs.htgen-${config._module.args.name}";
        name = lib.mkOption {
          type = lib.types.str;
          default = config._module.args.name;
        };
        package = lib.mkOption {
          default = pkgs.htgen;
          type = lib.types.package;
        };
        port = lib.mkOption {
          type = lib.types.int;
        };
        script = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
        scriptFile = lib.mkOption {
          type = lib.types.nullOr (lib.types.either lib.types.package lib.types.path);
          default = null;
        };
        username = lib.mkOption {
          type = lib.types.str;
          default = "htgen-${config.name}";
          defaultText = "htgen-‹name›";
        };
      };
    }));
  };
  config = {
    systemd.services = lib.mapAttrs' (name: htgen:
      lib.nameValuePair "htgen-${name}" {
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        environment = {
          HTGEN_PORT = toString htgen.port;
          STATEDIR = "/var/lib/${htgen.username}";
        }
        // optionalAttr "HTGEN_SCRIPT" htgen.script
        // optionalAttr "HTGEN_SCRIPT_FILE" htgen.scriptFile
        ;
        serviceConfig = {
          SyslogIdentifier = "htgen";
          User = htgen.username;
          DynamicUser = true;
          StateDirectory = htgen.username;
          PrivateTmp = true;
          Restart = "always";
          ExecStart = "${htgen.package}/bin/htgen --serve";
        };
      }
    ) config.krebs.htgen;
  };
}
