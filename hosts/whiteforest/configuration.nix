{
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  myOptions.vars.withGui = true;
  myOptions.amdgpu.enable = true;
  myOptions.logitech.enable = true;
  myOptions.tablet.enable = true;

  myOptions.deadlockModManager.enable = true;
  myOptions.teamspeak.enable = true;
  myOptions.android.enable = true;
  myOptions.protonvpn.enable = true;
  myOptions.memory.enable = true;
  myOptions.fish.enable = true;
  myOptions.neovim.enable = true;
  myOptions.miniflux.enable = true;

  myOptions.impermanence = {
    enable = true;
    tmpfsRoot = false; # Phase 1: test persistence declarations without tmpfs root
    rootUuid = "b41e5b4b-5020-4c15-bd40-0f78d2c8e237";
  };

  services.rss-archive-proxy = {
    enable = true;
    configFile = ./rss-archive-proxy.yaml;
  };

  myOptions.miniflux.feeds = {
    News = {
      "RTÉ News" = {url = "https://www.rte.ie/feeds/rss/?index=/news/";};
      "The Irish Times" = {url = "https://www.irishtimes.com/cmlink/the-irish-times-news-1.1319192";};
      "Financial Times (archived)" = {url = "http://127.0.0.1:8090/feed/financial-times";};
    };
    Tech = {
      "Lobsters" = {url = "https://lobste.rs/rss";};
    };
    Podcasts = {
      "Lemonade Stand" = {url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCwVevVbti5Uuxj6Mkl5NHRA";};
    };
    "Engineering Blogs" = {
      "Sean Goedecke" = {url = "https://www.seangoedecke.com/rss.xml";};
      "Paged Out!" = {url = "https://pagedout.institute/rss.xml";};
    };
  };

  myOptions.hyprland.monitors = [
    "DP-3, 3440x1440@144, 2560x0, 1"
    "HDMI-A-1, 2560x1440@60, 0x0, 1"
  ];

  boot.kernelPackages = pkgs.linuxPackages_zen;

  networking.hostName = "whiteforest";

  services.resolved.enable = true;

  system.stateVersion = "25.11";
}
