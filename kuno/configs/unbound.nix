{ pkgs, ... }:
{
  services.unbound = {
    enable = true;
    settings = {
      server = {
        interface = [
          "127.0.0.1@53"
          "mycelium@53"
          "wg0@53"
        ];
        access-control = [
          "::/0 allow"
          "0.0.0.0/0 allow"
        ];
      };
      auth-zone = [
        {
          name = "m.";
          zonefile = "/etc/panda/m.zone";
        }
        {
          name = "w.";
          zonefile = "/etc/panda/w.zone";
        }
      ];
    };
  };
}
