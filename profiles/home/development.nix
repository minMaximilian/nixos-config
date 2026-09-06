{pkgs, ...}: {
  imports = [
    ../../modules/home/core/agent-rules
    ../../modules/home/core/amp
    ../../modules/home/core/claude-code
    ../../modules/home/core/codex
    ../../modules/home/core/impeccable
    ../../modules/home/core/omp
    ../../modules/home/core/odin
    ../../modules/home/core/zig
    ../../modules/home/core/intellij
    ../../modules/home/core/java
  ];
  home.packages = with pkgs; [go gopls go-tools devenv packwiz];
  myOptions = {
    agentRules.enable = true;
    amp.enable = true;
    claude-code.enable = true;
    codex.enable = true;
    impeccable.enable = true;
    omp.enable = true;
    odin.enable = true;
    zig.enable = true;
    intellij.enable = true;
    java.enable = true;
    neovim.debug.enable = true;
    neovim.godot.enable = true;
  };
}
