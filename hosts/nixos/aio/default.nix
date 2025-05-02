###############################################################
#
#  Genesis - personal server
#
#  NixOs running on Ryzne 5 5600, Intel Arc A380, 32 GB RAM
#
###############################################################

{
    inputs,
    lib,
    config,
    pkgs,
    ...
}:
{
    imports = lib.flatten [
        #
        # ========== Hardware ==========
        #
        ./hardware-configuration.nix
        inputs.hardware.nixosModules.common-cpu-amd
        inputs.hardware.nixosModules.common-pc-ssd

        #
        # ========= Disk Layout =========
        #
        inputs.disko.nixosModules.disko
        (lib.custom.relativeToRoot "hosts/common/disks/genesis.nix")

        (map lib.custom.relativeToRoot [
          "hosts/common/core"

        #
        # ========= Optional pkgs =========
        #

        ])
    ];
}
