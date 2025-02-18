{config}: let
  inherit (config.colorScheme) palette;
in ''
  * {
    border: none;
    font-family: monospace;
    font-size: 13px;
    min-height: 20px;
  }

  window#waybar {
    background-color: #${palette.base00};
    color: #${palette.base05};
    border-bottom: 2px solid #${palette.base0D};
  }

  #workspaces {
    margin: 0 4px;
  }

  #workspaces button {
    padding: 0 5px;
    color: #${palette.base05};
    border: 2px solid #${palette.base01};
    margin: 4px 2px;
    border-radius: 2px;
    background-color: #${palette.base01};
  }

  #workspaces button.active {
    color: #${palette.base00};
    background-color: #${palette.base0D};
    border-color: #${palette.base0D};
  }

  #workspaces button:hover {
    background-color: #${palette.base02};
    color: #${palette.base05};
    border-color: #${palette.base02};
  }

  #clock,
  #battery,
  #cpu,
  #memory,
  #network,
  #pulseaudio,
  #tray {
    padding: 0 8px;
    margin: 4px 2px;
    color: #${palette.base05};
    background-color: #${palette.base01};
    border-radius: 2px;
  }

  #battery.warning {
    background-color: #${palette.base09};
    color: #${palette.base00};
  }

  #battery.critical {
    background-color: #${palette.base08};
    color: #${palette.base00};
  }

  #network.disconnected {
    background-color: #${palette.base08};
  }

  #tray {
    margin-right: 4px;
  }

  #pulseaudio.muted {
    background-color: #${palette.base01};
    color: #${palette.base03};
  }

  #window {
    margin: 4px;
    padding: 0 8px;
    background-color: #${palette.base01};
    border-radius: 2px;
  }
''
