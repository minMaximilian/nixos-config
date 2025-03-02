{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.myOptions.btop;
in {
  options.myOptions.btop = {
    enable =
      mkEnableOption "btop system monitor"
      // {
        default = true;
      };
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.myOptions.vars.username} = {pkgs, config, ...}: let
      inherit (config.colorScheme) palette;
      
      # Create a custom theme file that uses the system color scheme
      customTheme = ''
        #Custom btop theme using system colors
        
        # Main background, empty for terminal default, need to be empty if you want transparent background
        theme[main_bg]=""
        
        # Main text color
        theme[main_fg]="#${palette.base05}"
        
        # Title color for boxes
        theme[title]="#${palette.base05}"
        
        # Highlight color for keyboard shortcuts
        theme[hi_fg]="#${palette.base0D}"
        
        # Background color of selected item in processes box
        theme[selected_bg]="#${palette.base02}"
        
        # Foreground color of selected item in processes box
        theme[selected_fg]="#${palette.base05}"
        
        # Color of inactive/disabled text
        theme[inactive_fg]="#${palette.base03}"
        
        # Color of text appearing on top of graphs, i.e uptime and current network graph scaling
        theme[graph_text]="#${palette.base04}"
        
        # Misc colors for processes box including mini cpu graphs, details memory graph and details status text
        theme[proc_misc]="#${palette.base0B}"
        
        # Cpu box outline color
        theme[cpu_box]="#${palette.base0D}"
        
        # Memory/disks box outline color
        theme[mem_box]="#${palette.base0E}"
        
        # Net up/down box outline color
        theme[net_box]="#${palette.base0F}"
        
        # Processes box outline color
        theme[proc_box]="#${palette.base0C}"
        
        # Box divider line and small boxes line color
        theme[div_line]="#${palette.base03}"
        
        # Temperature graph colors
        theme[temp_start]="#${palette.base0D}"
        theme[temp_mid]="#${palette.base0E}"
        theme[temp_end]="#${palette.base08}"
        
        # CPU graph colors
        theme[cpu_start]="#${palette.base0D}"
        theme[cpu_mid]="#${palette.base0C}"
        theme[cpu_end]="#${palette.base0B}"
        
        # Mem/Disk free meter
        theme[free_start]="#${palette.base0D}"
        theme[free_mid]="#${palette.base0C}"
        theme[free_end]="#${palette.base0B}"
        
        # Mem/Disk cached meter
        theme[cached_start]="#${palette.base0D}"
        theme[cached_mid]="#${palette.base0C}"
        theme[cached_end]="#${palette.base0B}"
        
        # Mem/Disk available meter
        theme[available_start]="#${palette.base0D}"
        theme[available_mid]="#${palette.base0C}"
        theme[available_end]="#${palette.base0B}"
        
        # Mem/Disk used meter
        theme[used_start]="#${palette.base08}"
        theme[used_mid]="#${palette.base09}"
        theme[used_end]="#${palette.base0A}"
        
        # Download graph colors
        theme[download_start]="#${palette.base0D}"
        theme[download_mid]="#${palette.base0C}"
        theme[download_end]="#${palette.base0B}"
        
        # Upload graph colors
        theme[upload_start]="#${palette.base08}"
        theme[upload_mid]="#${palette.base09}"
        theme[upload_end]="#${palette.base0A}"
      '';
    in {
      programs.btop = {
        enable = true;
        settings = {
          vim_keys = true;
          rounded_corners = true;
          graph_symbol = "braille";
          update_ms = 1000;
          color_theme = "custom";
        };
      };
      
      # Create the custom theme file
      xdg.configFile."btop/themes/custom.theme".text = customTheme;
    };
  };
}
