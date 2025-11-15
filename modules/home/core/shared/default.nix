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
        sessionVariables = lib.mkMerge [
          {
            _JAVA_AWT_WM_NONREPARENTING = "1";
          }
        ];
      };
      systemd.user.startServices = if config.myOptions.vars.withGui then "sd-switch" else false;
    };
  };
}
