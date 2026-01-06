{
  config,
  pkgs,
  pkgs-graalvm21,
  lib,
  inputs,
  self,
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
      inherit inputs self pkgs-graalvm21;
    };
    users.${config.myOptions.vars.username} = {
      imports = [
        ../../home
        ../../shared/vars.nix
      ];
      myOptions.vars = config.myOptions.vars;

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
