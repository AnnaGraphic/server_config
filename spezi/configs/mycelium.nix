{ pkgs, ... }: {
  services.mycelium = {
    enable = true;
    openFirewall = true;
  };
}
