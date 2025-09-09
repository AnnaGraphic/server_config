#! /bin/sh

# usage: ./deploy.sh

set -efu

name=udo
host=udo.m
host=localhost

rsync -rlptD "$HOME"/Sync/secrets/shared/hosts root@"$host":/etc/panda/hosts
rsync -rlptD "$HOME"/Sync/secrets/udo/ root@"$host":/etc/panda/secrets/
rsync -rlptD --delete \
    --exclude=.git \
    "$HOME"/Sync/code/server/ root@"$host":/etc/nixos/

ssh root@"$host" ln -vsnf "$name"/configuration.nix /etc/nixos/configuration.nix

ssh root@"$host" nixos-rebuild switch
