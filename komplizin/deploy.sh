#! /bin/sh

# usage: ./deploy.sh

set -efu

name=komplizin
host=komplizin.m

rsync -rlptD /home/panda/Sync/shared-secrets/hosts root@"$host":/etc/panda/hosts
rsync -rlptD /home/panda/Sync/komplizin-secrets/ root@"$host":/etc/panda/secrets/
rsync -rlptD --delete \
    --exclude=.git \
    --exclude=/configuration.nix \
    --exclude=/kleingeist \
    "$HOME"/projekte/server/ root@"$host":/etc/nixos/

ssh root@"$host" ln -vsnf "$name"/configuration.nix /etc/nixos/configuration.nix

ssh root@"$host" nixos-rebuild switch
