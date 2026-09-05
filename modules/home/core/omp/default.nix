{
  config,
  inputs ? {},
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf optionals;

  cfg = config.myOptions.omp;
  hasOmp = inputs ? omp;
in {
  imports = optionals hasOmp [
    inputs.omp.homeManagerModules.default
  ];

  options.myOptions.omp.enable =
    mkEnableOption "OMP coding agent";

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = hasOmp;
        message = "myOptions.omp requires inputs.omp";
      }
    ];

    programs.omp.enable = true;
  };
}
