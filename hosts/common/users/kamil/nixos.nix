{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  hostSpec = config.hostSpec;
  ifGroupsExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;

  sopsHashedPasswordFile = lib.optionalString (
    !config.hostSpec.isMinimal
  ) config.sops.secrets."passwords/${hostSpec.username}".path;   
in 
{
  users.mutableUsers = false;
  users.users.${hostSpec.username} = {
    home = "/home/${hostSpec.username}";
    isNormalUser = true;
    hashedPasswordFile = sopsHashedPasswordFile;

    extraGroups = lib.flatten [
      "wheel"
      (ifGroupsExist [
        "audio"
        "video"
        "docker"
        "git"
        "networkmanager"
      ])
    ];
  };

  programs.git.enable = true;

  users.users.root = {
    shell = pkgs.zsh;
    hashedPasswordFile = config.users.users.${hostSpec.username}.hashedPasswordFile;
    hashedPassword = config.users.users.${hostSpec.username}.hashedPassword; # This comes from hosts/common/optional/minimal.nix and gets overridden if sops is working
    openssh.authorizedKeys.keys = config.users.users.${hostSpec.username}.openssh.authorizedKeys.keys; # root's ssh keys are mainly used for remote deployment.
  };
}
// lib.optionalAttrs (inputs ? "home-manager") {

  home-manager.users.root = lib.optionalAttrs (!hostSpec.isMinimal) {
    home.stateVersion = "24.11";
    programs.zsh = {
      enable = true;
      plugins = [
        # Just do sth in the future, for now, it's too much to port power10k config...
      ];
    };
  };
}
