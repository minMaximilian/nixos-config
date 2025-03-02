{config}: let
  inherit (config.colorScheme) palette;
in ''
  * {
    font-family: "JetBrainsMono Nerd Font";
    font-size: 14px;
    min-height: 0;
    border: none;
    border-radius: 0;
  }

  window#waybar {
    background-color: #${palette.base00};
    color: #${palette.base05};
  }

  #workspaces {
    background-color: #${palette.base01};
    margin: 5px;
    margin-left: 10px;
    border-radius: 5px;
  }

  #workspaces button {
    padding: 0 10px;
    color: #${palette.base05};
  }

  #workspaces button.active {
    color: #${palette.base00};
    background-color: #${palette.base0B};
  }

  #workspaces button:hover {
    box-shadow: inherit;
    text-shadow: inherit;
    background: #${palette.base02};
  }

  #workspaces button.urgent {
    background-color: #${palette.base08};
  }

  #window {
    margin: 5px;
    padding-left: 10px;
    padding-right: 10px;
    border-radius: 5px;
    transition: none;
    color: #${palette.base05};
    background: #${palette.base01};
  }

  #clock, #battery, #cpu, #memory, #network, #pulseaudio, #tray {
    margin: 5px;
    margin-right: 10px;
    padding: 0 10px;
    border-radius: 5px;
    background-color: #${palette.base01};
    color: #${palette.base05};
  }

  #clock {
    margin-right: 10px;
  }

  #battery.charging {
    color: #${palette.base0B};
  }

  #battery.warning:not(.charging) {
    background-color: #${palette.base0A};
    color: #${palette.base00};
  }

  #battery.critical:not(.charging) {
    background-color: #${palette.base08};
    color: #${palette.base00};
  }

  #network.disconnected {
    background-color: #${palette.base08};
  }

  #pulseaudio.muted {
    background-color: #${palette.base0A};
    color: #${palette.base00};
  }

  tooltip {
    background: #${palette.base00};
    border: 1px solid #${palette.base05};
  }

  tooltip label {
    color: #${palette.base05};
  }
''
