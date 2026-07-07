{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.dic
  ];
}
