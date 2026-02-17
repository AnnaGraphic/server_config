{ pkgs, ... }:
{
  boot.initrd = {
    availableKernelModules = [ "e1000e" ];
    network = {
      enable = true;
      udhcpc.enable = true;
      flushBeforeStage2 = true;
      ssh = {
        enable = true;
        port = 22;
        authorizedKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDMe6DnF20BPefG3m9Naf/PdTJ/pjC1TTpsXtZQQ52We panda@spezi" ];
        hostKeys = [ "/home/panda/Sync/secrets/udo/udo-initrd-key" ];
      };
    };
  };
}
