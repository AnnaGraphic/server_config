#! /bin/sh

# usage: ./deploy.sh

set -efu

name=wsl2
host=wsl2.m

rsync -rlptD /home/panda/Sync/shared-secrets/hosts root@"$host":/etc/nixos/hosts
rsync -rlptD /home/panda/Sync/wsl2-secrets/ root@"$host":/etc/nixos/secrets/
rsync -rlptD --delete \
    --exclude=.git \
    --exclude=/configuration.nix \
    --exclude=/kleingeist \
    "$HOME"/projekte/server/ root@"$host":/etc/nixos/

ssh root@"$host" ln -vsnf "$name"/configuration.nix /etc/nixos/configuration.nix

ssh root@"$host" nixos-rebuild switch
