{...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  myOptions.vars.withGui = true;
  myOptions.memory.enable = true;
  myOptions.fish.enable = true;
  myOptions.neovim.enable = true;
  myOptions.multimedia.enable = true;

  networking.hostName = "ravenholm";

  system.stateVersion = "24.11";
}
