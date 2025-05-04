{
  config,
  lib,
  pkgs,
  hostSpec,
  ...
}:

{
  imports = lib.flatten [
    (map lib.custom.relativeToRoot [
      "internal/common/host-spec.nix"
    ])
  ];

  inherit hostSpec;

  services.ssh-agent.enable = true;

  ################## home manager config here ########################
  home = {
    username = lib.mkDefault config.hostSpec.username;
    stateVersion = lib.mkDefault "24.11";
    homeDirectory = lib.mkDefault config.hostSpec.home;
  };

  ####################################################################

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = false;
    };
  };

  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
