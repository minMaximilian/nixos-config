{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.myOptions.neovim;
  username = config.myOptions.vars.username;
in {
  options.myOptions.neovim = {
    enable = mkEnableOption "Neovim";
  };

  config = mkIf cfg.enable {
    home-manager.users.${username}.myOptions.neovim.enable = true;
  };
}
