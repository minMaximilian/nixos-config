{
  config,
  pkgs,
  lib,
  inputs,
  self,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkMerge
    ;

  cfg = config.myOptions.hyprland;
  username = config.myOptions.vars.username;
  palette = config.myOptions.theme.colorScheme.palette;
in {
  options.myOptions.hyprland = {
    enable =
      mkEnableOption "Hyprland Window Manager and related user settings"
      // {
        default = config.myOptions.vars.withGui;
      };
  };

  config = mkIf cfg.enable {
    home-manager.users.${username} = {
      pkgs,
      config,
      lib,
      ...
    }: {
      wayland.windowManager.hyprland = {
        enable = true;
        systemd.enable = true;
        package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        settings = mkMerge [
          {
            "$mod" = "SUPER";
            "$active" = "rgb(${palette.base0D})";
            "$inactive" = "rgb(${palette.base02})";
            "$groupActive" = "rgb(${palette.base0E})";
            "$groupInactive" = "rgb(${palette.base01})";
            "$text" = "rgb(${palette.base05})";
            "$warning" = "rgb(${palette.base08})";

            exec-once = import ./exec-once.nix {inherit pkgs;};
            env = import ./env.nix;
            dwindle = import ./layout.nix;
            input = import ./input.nix;
            misc = import ./misc.nix;
            workspace = import ./workspace.nix;
            bind = import ./keybinds.nix {inherit pkgs;};
          }
          (import ./style.nix {inherit palette;})
        ];
      };
    };
  };
}
