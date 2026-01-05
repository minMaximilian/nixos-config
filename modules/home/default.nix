{inputs, ...}: {
  imports = [
    ./core
    ./gui
    inputs.zen-browser.homeModules.default
  ];
}
