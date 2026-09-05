{
  pkgs,
  config,
  inputs,
  lib,
  ...
}: let
  businessPostArchiveProxyConfig = pkgs.writeText "rss-archive-proxy-business-post.yaml" ''
    server:
      port: 8091
      host: "127.0.0.1"

    poll_interval: 30
    cache_path: "/var/lib/rss-archive-proxy-business-post/cache.json"

    feeds:
      - name: "Business Post"
        source_url: "https://www.businesspost.ie/feed/"
        strategy: "archive.ph"
  '';
in {
  imports = [
    ./hardware-configuration.nix
  ];

  myOptions.vars.withGui = true;
  myOptions.amdgpu.enable = true;
  myOptions.amdgpu.rocm.enable = true;
  myOptions.ml.enable = true;
  myOptions.logitech.enable = true;
  myOptions.tablet.enable = true;

  myOptions.deadlockModManager.enable = true;
  myOptions.teamspeak.enable = true;
  myOptions.protonvpn.enable = true;
  myOptions.memory.enable = true;
  myOptions.fish.enable = true;
  myOptions.neovim.enable = true;
  myOptions.multimedia.enable = true;
  myOptions.miniflux.enable = true;

  myOptions.preservation = {
    enable = true;
    tmpfsRoot = true;
    rootUuid = "b41e5b4b-5020-4c15-bd40-0f78d2c8e237";
    declarativeUsers = {
      max = "/persist/etc/passwords/max";
      root = "/persist/etc/passwords/root";
    };
  };

  services.rss-archive-proxy = {
    enable = true;
    configFile = ./rss-archive-proxy.yaml;
  };

  systemd.services = {
    caddy.unitConfig = {
      After = lib.mkForce ["" "network.target"];
      Requires = lib.mkForce [""];
    };

    rss-archive-proxy = {
      after = lib.mkForce ["network.target"];
      wants = lib.mkForce [];
    };

    # ponytail: separate instance until the proxy isolates caches per feed.
    rss-archive-proxy-business-post = {
      description = "Business Post RSS Archive Proxy";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${config.services.rss-archive-proxy.package}/bin/rss-archive-proxy -config ${businessPostArchiveProxyConfig}";
        Restart = "on-failure";
        RestartSec = 10;
        StateDirectory = "rss-archive-proxy-business-post";
      };
    };
  };

  myOptions.miniflux.feeds = {
    News = {
      "RTÉ News" = {url = "https://www.rte.ie/feeds/rss/?index=/news/";};
      "The Irish Times" = {url = "https://www.irishtimes.com/cmlink/the-irish-times-news-1.1319192";};
      "Financial Times (archived)" = {url = "http://127.0.0.1:8090/feed/financial-times";};
      "Business Post (archived)" = {url = "http://127.0.0.1:8091/feed/business-post";};
    };
    Tech = {
      "Lobsters" = {url = "https://lobste.rs/rss";};
    };
    Podcasts = {
      "Lemonade Stand" = {url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCwVevVbti5Uuxj6Mkl5NHRA";};
    };
    YouTube = {
      "Tom Scott" = {url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCBa659QWEk1AI4Tg--mrJ2A";};
      "BeamBuddy" = {url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCTPQU7wiEr423xqD-2yJRBQ";};
      "Super Eyepatch Wolf" = {url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCtGoikgbxP4F3rgI9PldI9g";};
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
