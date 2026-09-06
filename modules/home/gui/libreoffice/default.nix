{
  config,
  lib,
  localPackages,
  ...
}: {
  options.myOptions.libreoffice.enable = lib.mkEnableOption "LibreOffice office suite";

  config = lib.mkIf config.myOptions.libreoffice.enable {
    home.packages = [localPackages.libreoffice];
  };
}
