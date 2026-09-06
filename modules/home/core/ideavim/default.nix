{
  config,
  lib,
  ...
}: {
  options.myOptions.ideavim.enable = lib.mkEnableOption "shared IdeaVim settings and bindings";

  config = lib.mkIf config.myOptions.ideavim.enable {
    home.file.".ideavimrc".source = ./ideavimrc;
  };
}
