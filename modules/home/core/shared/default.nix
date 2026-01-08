{
  config,
  lib,
  ...
}: {
  systemd.user.startServices =
    if config.myOptions.vars.withGui
    then "sd-switch"
    else false;

  # Hide unwanted system apps from rofi/launchers
  xdg.desktopEntries = lib.mkIf config.myOptions.vars.withGui {
    xterm = {
      name = "XTerm";
      exec = "xterm";
      noDisplay = true;
    };
  };
}
