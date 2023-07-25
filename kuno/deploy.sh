#! /bin/sh

# usage: ./deploy.sh

set -efu

name=kuno
host=130.61.237.100

rsync -va --delete "$HOME"/projekte/server/"$name"/ root@"$host":/etc/nixos/
ssh root@"$host" nixos-rebuild switch
