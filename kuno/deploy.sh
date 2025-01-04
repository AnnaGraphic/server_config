#! /bin/sh

# usage: ./deploy.sh

set -efu

name=kuno
host=130.61.237.100

rsync -v -rlptD /home/panda/Sync/shared-secrets/hosts root@"$host":/etc/panda/hosts
rsync -v -rlptD /home/panda/Sync/kuno-secrets/ root@"$host":/etc/panda/secrets/
rsync -v -rlptD --delete --exclude=.git --exclude=/configuration.nix --exclude=kleingeist/ "$HOME"/projekte/server/ root@"$host":/etc/nixos/

# for /server/kuno/pkgs/portfolio
rsync -v -rlptD --delete --exclude=.git /home/panda/projekte/portfolio/ root@"$host":/etc/panda/portfolio/

ssh root@"$host" ln -vsnf "$name"/configuration.nix /etc/nixos/configuration.nix

ssh root@"$host" nixos-rebuild switch
