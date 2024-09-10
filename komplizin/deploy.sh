#! /bin/sh

# usage: ./deploy.sh

set -efu

name=komplizin
host=komplizin.m

rsync -va /home/panda/Sync/shared-secrets/hosts root@"$host":/etc/panda/hosts
rsync -va /home/panda/Sync/komplizin-secrets/ root@"$host":/etc/panda/secrets/
rsync -va --delete --exclude=.git --exclude=/configuration.nix "$HOME"/projekte/server/ root@"$host":/etc/nixos/

ssh root@"$host" ln -vsnf "$name"/configuration.nix /etc/nixos/configuration.nix

ssh root@"$host" nixos-rebuild switch
