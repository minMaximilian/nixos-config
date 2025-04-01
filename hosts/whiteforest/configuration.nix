{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  myOptions.vars.withGui = true;
  myOptions.amdgpu.enable = true; # Enable AMD GPU support for desktop

  # Enable boot module with Windows dual-boot
  myOptions.boot = {
    enable = true;
    loader = "systemd-boot";
    configurationLimit = 10;
    dualBoot = {
      enable = true;
      windows.enable = true;
      # Uncomment and modify if your Windows EFI is in a non-standard location
      # windows.efiPath = "/EFI/Microsoft/Boot/bootmgfw.efi";
    };
  };

  networking.hostName = "whiteforest";
  networking.networkmanager.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;

  environment.systemPackages = with pkgs; [
    code-cursor
  ];

  system.stateVersion = "24.11";
}
