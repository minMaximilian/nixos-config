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
    ../../modules/nixos/miniflux
    inputs.rss-archive-proxy.nixosModules.default
  ];

  myOptions.miniflux.enable = true;

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
}
