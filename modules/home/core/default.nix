{lib, ...}: {
  imports = [
    ./agent-rules
    ./amp
    ./claude-code
    ./codex
    ./impeccable
    ./opencode
    ./omp
    ./shared
    ./git
    ./git-hooks
    ./fish
    ./neovim
    ./btop
    ./devenv
    ./golang
    ./odin
    ./zellij
    ./jj

    ./zig

    ./intellij
    ./java
    ./packwiz
  ];

  config.myOptions = {
    agentRules.enable = lib.mkDefault true;
    amp.enable = lib.mkDefault true;
    claude-code.enable = lib.mkDefault true;
    codex.enable = lib.mkDefault true;
    impeccable.enable = lib.mkDefault true;
    omp.enable = lib.mkDefault true;
    git.enable = lib.mkDefault true;
    git.hooks.enable = lib.mkDefault true;
    fish.enable = lib.mkDefault true;
    neovim.enable = lib.mkDefault true;
    btop.enable = lib.mkDefault true;
    devenv.enable = lib.mkDefault true;
    golang.enable = lib.mkDefault true;
    odin.enable = lib.mkDefault true;
    zellij.enable = lib.mkDefault true;
    jj.enable = lib.mkDefault true;
    zig.enable = lib.mkDefault true;
    intellij.enable = lib.mkDefault true;
    java.enable = lib.mkDefault true;
    packwiz.enable = lib.mkDefault true;
  };
}
