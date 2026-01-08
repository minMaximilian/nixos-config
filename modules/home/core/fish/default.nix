{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkOption mkIf types;
  cfg = config.myOptions.fish;
in {
  options.myOptions.fish = {
    enable = lib.mkEnableOption "Fish Shell";
  };

  config = mkIf cfg.enable {
    home.packages = lib.attrValues {
      inherit
        (pkgs)
        zoxide
        fzf
        fd
        bat
        ;
    };

    programs = {
      fish = {
        enable = true;
        plugins = import ./plugins.nix {inherit pkgs;};
        functions = {
          fish_greeting = "";
          fish_mode_prompt = ''
            switch $fish_bind_mode
              case default
                set_color --bold red
                echo '[N] '
              case insert
                set_color --bold green
                echo '[I] '
              case replace_one
                set_color --bold yellow
                echo '[R] '
              case visual
                set_color --bold magenta
                echo '[V] '
            end
            set_color normal
          '';
        };
        shellAbbrs = {
          cat = "bat";
        };
        interactiveShellInit = ''
          fish_vi_key_bindings
        '';
      };
      man.generateCaches = true;
      zoxide = {
        enable = true;
        options = ["--cmd cd"];
      };
    };
  };
}
