{ pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.writers.writeDashBin "sharestuff" ''
      set -efu

      # sharestuff LOKALE_DATEI [REMOTE_NAME]

      # $# anzahl der args die an sharestuff übergeben werden
      case $# in
        1)
          ${pkgs.openssh}/bin/scp "$1" shell.c-base.org:public_html/
          echo https://panda.crew.c-base.org/"$(${pkgs.coreutils}/bin/basename "$1")"
          ;;
        2)
          ${pkgs.openssh}/bin/scp "$1" shell.c-base.org:public_html/"$2"
          echo https://panda.crew.c-base.org/"$2"
          ;;
        *)
          echo $0: error: bad number of arguments: $# >&2
          exit 1
          ;;
      esac
    '')
  ];
}
