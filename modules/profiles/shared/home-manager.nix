{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = {
      inherit inputs;
    };
    users.${config.myOptions.vars.username} = {
      home = {
        username = config.myOptions.vars.username;
        homeDirectory = "/home/${config.myOptions.vars.username}";
        stateVersion = config.system.stateVersion;
        sessionVariables = {
          _JAVA_AWT_WM_NONREPARENTING = "1";
        };
      };
    };
  };
}
