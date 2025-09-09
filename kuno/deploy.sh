#! /bin/sh

# usage: ./deploy.sh

set -efu

name=kuno
host=130.61.237.100

rsync -v -rlptD /home/panda/Sync/secrets/shared/hosts root@"$host":/etc/panda/hosts
rsync -v -rlptD /home/panda/Sync/secrets/kuno/ root@"$host":/etc/panda/secrets/
rsync -v -rlptD --delete --exclude=.git --exclude=/configuration.nix --exclude=kleingeist/ "$HOME"/Sync/code/server/ root@"$host":/etc/nixos/

# for /server/kuno/pkgs/portfolio
rsync -v -rlptD --delete --exclude=.git /home/panda/Sync/code/portfolio/ root@"$host":/etc/panda/portfolio/

# ensure mountpoint for storage box:
ssh root@"$host" mkdir -p /mnt/arbeit_und_illustration

ssh root@"$host" ln -vsnf "$name"/configuration.nix /etc/nixos/configuration.nix

ssh root@"$host" nixos-rebuild switch
