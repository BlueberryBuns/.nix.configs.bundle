{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:

{

  hostSpec = {
    hostName = "aio";
    isMinimal = true;
    useYubikey = true;
    persistFolder = "/persist";
  };

  imports = lib.flatten [
    ./hardware-configuration.nix
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-gpu-intel
    inputs.hardware.nixosModules.common-pc-ssd

    inputs.disko.nixosModules.disko
    (lib.custom.relativeToRoot "hosts/common/disks/btrfs-impermanence.nix")
    {
        _module.args = {
          device = "/dev/nvme0n1";
          withSwap = true;
          swapSize = 32;
        };
    }

    (map lib.custom.relativeToRoot [
        "hosts/common/core"

        "hosts/common/optional/openssh.nix"
    ])
  ];

  # TODO(Kamil): Add IPv6 networking later...
  networking = {
    networkmanager.enable = true;
    enableIPv6 = false;
  };

  boot = {
    initrd = { systemd.enable = true; };
    kernelPackages = pkgs.unstable.linuxPackages_latest;
    
    loader = {
      timeout = 3;
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        # When using plymouth, initrd can expand by a lot each time, so limit how many we keep around
        configurationLimit = lib.mkDefault 10;
      };
    };
  };

  hardware.graphics.enable = true;
  environment.systemPackages = builtins.attrValues {
    inherit (pkgs)
      ;
  };

  system.stateVersion = "24.11";

}
