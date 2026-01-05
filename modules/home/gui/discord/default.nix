{
  config,
  lib,
  inputs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.myOptions.discord;
in {
  imports = [
    inputs.nixcord.homeModules.nixcord
  ];

  options.myOptions.discord = {
    enable =
      mkEnableOption "Discord via Nixcord"
      // {
        default = true;
      };
  };

  config = mkIf cfg.enable {
    programs.nixcord = {
      enable = true;
      discord.enable = false;
      vesktop.enable = true;
    };
  };
}
