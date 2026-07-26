{
  config,
  lib,
  ...
}: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings.hermes = {
      HostName = "127.0.0.1";
      Port = 2222;
      User = "max";
    };
  };

  systemd.user.startServices =
    if config.myOptions.vars.withGui
    then "sd-switch"
    else false;

  # Hide unwanted system apps from launchers.
  xdg.desktopEntries = lib.mkIf config.myOptions.vars.withGui {
    xterm = {
      name = "XTerm";
      exec = "xterm";
      noDisplay = true;
    };
  };
}
