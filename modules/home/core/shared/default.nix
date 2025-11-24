{
  config,
  lib,
  ...
}: {
  systemd.user.startServices =
    if config.myOptions.vars.withGui
    then "sd-switch"
    else false;
}
