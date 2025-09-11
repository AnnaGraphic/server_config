# nixos server config
## quickstart
To initialize a host to use the server configuration,
its /etc/nixos directory has to point to this repository.

E.g. for spezi:
```sh
    mkdir /etc/nixos
    ln -s /home/panda/Sync/code/server /etc/nixos/
    ln -s server/spezi/configuration.nix /etc/nixos/
```
