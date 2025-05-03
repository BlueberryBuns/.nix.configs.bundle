{
  description = "Nix package manager monorepo";

  outputs = 
  {
    self,
    nixpkgs,
    # nix-darwin,
    ...
  } @ inputs:
  let
    inherit (self) outputs;
  
    forAllSystems = nixpkgs.lib.genAttrs [
      "x86_64-linux"
      # "aarch64-linux"
      # "aarch64-darwin"
    ];

    lib = nixpkgs.lib.extend (self: super: {custom = import ./lib { inherit (nixpkgs) lib; }; });
  in
  {
  # NixOS specific configurations
  nixosConfigurations = builtins.listToAttrs (
    map (host: {
      name = host;
      value = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs lib;
          isDarwin = false;
        };
        modules = [ ./hosts/nixosConfigurations/${host} ];
      };
    }) (builtins.attrNames (builtins.readDir ./hosts/nixosConfigurations))
  );

  
  # MacOS specific configurations
  # darwinConfiguration = builtins.listToAttrs (
  #  map (host: {
  #    name = host;
  #    value = nix-darwin.lib.darwinSystem {
  #      specialArgs = {
  #        inherit inputs outputs lib;
  #        isDarwin = true;
  #      };
  #      modules = [ ./hosts/nixos/${host} ];
  #    };
  #  }) (builtins.attrNames (builtins.readDir ./hosts/darwin))
  # );

  formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
  overlays = import ./overlays { inherit inputs; };

  };
  inputs = {
    stylix.url = "github:danth/stylix/release-24.11";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:nixos/nixpkgs/nixpkgs-24.11-darwin";
    nix-darwin-stable.url = "github:nixos/nixpkgs/nixpkgs-24.11-darwin";
    nix-darwin-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    hardware.url = "github:nixos/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # secrects-private = {
    #  url = ""
    #  inputs = {};
    # };
  };

}
