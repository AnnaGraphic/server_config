{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.wetter
  ];
}
