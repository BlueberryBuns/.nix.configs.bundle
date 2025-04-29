{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:

{
  imports = lib.flatten [
    ./hardware-configuration.nix
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-pc-ssd

    (map lib.custom.relativeToRoot [
        "hosts/common/core"

    ])
  ];
}
