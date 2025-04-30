{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.hostSpec = {
    username = lib.mkOption {
      type = lib.types.str;
      description = "The username of the host";
    };
    
    hostName = lib.mkOption {
      type = lib.types.str;
      description = "The hostname of the host";
    };

    persistFolder = lib.mkOption {
      type = lib.types.str;
      description = "The folder to persist data if impermenance is enabled";
      default = "";
    };

    home = lib.mkOption {
      type = lib.types.str;
      description = "Home directory of the user";
      default = 
        let
          user = config.hostSpec.username;
        in
        if pkgs.stdenv.isLinux then "/home/${user}" else "/Users/${user}";
    };

    #
    # ============= Boolean flags ============= 
    #
    useYubikey = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Used to indicate if the host uses a yubikey";
    };

    isDarwin = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Used to indicate a host that is darwin";
    };

    isMinimal = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Used to specify minimal confuguration";
    };

    isServer = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Used to indicate a server host";
    };
  };

  config = {
    assertions = 
      let
        isImpermanent =
          config ? "system" && config.system ? "impermanence" && config.system.impermanence.enable;
      in 
      [
        {
          assertion = !isImpermanent || (isImpermanent && !("${config.hostSpec.persistentFolder}" == ""));
          message = "config.system.impermanence.enable is set to true, but no persistentFolder path is provided";
        }
      ];
  };
}
