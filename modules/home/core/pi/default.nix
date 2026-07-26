{
  config,
  inputs ? {},
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf optionals;

  cfg = config.myOptions.pi;
  hasPi = inputs ? pi;
  hasImpeccable = inputs ? impeccable;
in {
  imports = optionals hasPi [
    inputs.pi.homeModules.default
  ];

  options.myOptions.pi.enable =
    mkEnableOption "Pi coding agent";

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = hasPi;
        message = "myOptions.pi requires inputs.pi";
      }
      {
        assertion = hasImpeccable;
        message = "myOptions.pi requires inputs.impeccable";
      }
    ];

    programs.pi.coding-agent = {
      enable = true;
      skills = ["${inputs.impeccable}/.pi/skills/impeccable"];
      extensions = [
        "git:github:chandra447/pi-hermes-memory"
        "npm:pi-web-access"
      ];
    };

    home.packages = [
      config.programs.pi.coding-agent.finalPackage
    ];
  };
}
