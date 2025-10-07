#! /bin/sh

# usage: ./deploy.sh

set -efux

name=spezi
host=spezi.m

rsync -rlptD "$HOME"/Sync/secrets/spezi root@"$host":/etc/panda/secrets/
rsync -rlptD --delete \
    --exclude=.git \
    "$HOME"/Sync/code/server/ root@"$host":/etc/nixos/

ssh root@"$host" ln -vsnf "$name"/configuration.nix /etc/nixos/configuration.nix

ssh root@"$host" nixos-rebuild switch
