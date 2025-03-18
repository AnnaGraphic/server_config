{ pkgs, ... }:
let
  alacritty-cfg = theme:
    (pkgs.formats.toml {}).generate "alacritty.toml" {
      bell = {
        animation = "EaseOut";
        duration = 100;
        color = "#ff00ff";
      };
      font = {
        normal = {
          family = "DejaVu Sans Mono";
          style = "Regular";
        };
        bold = {
          family = "DejaVu Sans Mono";
          style = "Bold";
        };
        italic = {
          family = "DejaVu Sans Mono";
          style = "Italic";
        };
        bold_italic = {
          family = "DejaVu Sans Mono";
          style = "Bold Italic";
        };
        size = 8.2;
      };
    };
in
{
  environment.variables.TERMINAL = "alacritty";

  environment.etc."alacritty/default.toml".source = alacritty-cfg {
  };

  nixpkgs.overlays = [(self: super: {
    alacritty-panda = pkgs.symlinkJoin {
      name = "alacritty";
      paths = [
        (pkgs.writers.writeDashBin "alacritty" ''
          exec ${pkgs.alacritty}/bin/alacritty --config-file /etc/alacritty/default.toml "$@"
        '')
        pkgs.alacritty
      ];
    };
  })];
}
