{
  inputs,
  outputs,
  config,
  lib,
  pkgs,
  isDarwin,
  ...
}:
let
  platform = if isDarwin then "darwin" else "nixos";
  platformModules = "${platform}Modules";
in
{
  imports = lib.flatten [
    inputs.home-manager.${platformModules}.home-manager
    inputs.sops-nix.${platformModules}.sops

    (map lib.custom.relativeToRoot [
      "internal/common"

      "hosts/common/core/${platform}.nix"

      "hosts/common/users/kamil"
      "hosts/common/users/kamil/${platform}.nix"
    ])
  ];
  
  hostSpec = {
    username = "kamil";
  };
  
  networking.hostName = config.hostSpec.hostName;
  environment.systemPackages = [ pkgs.openssh ];

  # document the part about package manager
  home-manager.useGlobalPkgs = true;
  home-manager.backupFileExtension = "hmbk"; # Extends to: home manager backup

  #
  # ========== Overlays ==========
  #
  nixpkgs = {
    overlays = [
      outputs.overlays.default
    ];

    config = {
      allowUnfree = true;
    };
  };

  #
  # ========== Nix Nix Nix ==========
  #
  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      # See https://jackson.dev/post/nix-reasonable-defaults/
      connect-timeout = 5;
      log-lines = 25;
      min-free = 128000000; # 128MB
      max-free = 1000000000; # 1GB

      trusted-users = [ "@wheel" ];

      # Deduplicate and optimize nix store
      auto-optimise-store = true;
      warn-dirty = false;
      
      # disabled because it tries to compile package if binary fails to load
      # I don't think this one is required really, don't wanna have it locally
      # fallback = true; 

      allow-import-from-derivation = true;

      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  #
  # ========== Basic Shell Enablement ==========
  #
  # On darwin it's important this is outside home-manager
  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };
}
