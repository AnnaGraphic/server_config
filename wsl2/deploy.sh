#! /bin/sh

# usage: ./deploy.sh
# TODO: also deploy /etc/panda/secrets/wireguard-private-key (currently it has to be done manually)

set -efu

name=wsl2
host=wsl2.m

rsync -rlptD /home/panda/Sync/secrets/shared/hosts root@"$host":/etc/panda/hosts
rsync -rlptD /home/panda/Sync/secrets/wsl root@"$host":/etc/panda/secrets/
rsync -rlptD --delete \
    --exclude=.git \
    --exclude=/configuration.nix \
    --exclude=/kleingeist \
    "$HOME"/projekte/server/ root@"$host":/etc/nixos/

ssh root@"$host" ln -vsnf "$name"/configuration.nix /etc/nixos/configuration.nix

ssh root@"$host" nixos-rebuild switch
