{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption mkIf types mapAttrsToList;
  cfg = config.myOptions.miniflux;

  defaultCredentials = pkgs.writeText "miniflux-admin-credentials" ''
    ADMIN_USERNAME=admin
    ADMIN_PASSWORD=123456
  '';

  opmlContent = import ./opml.nix {inherit lib;} cfg.feeds;

  opmlFile = pkgs.writeText "miniflux-feeds.opml" opmlContent;

  # Build a JSON map of feed_url -> category_title from the declarative config
  feedCategoryMap = let
    pairs = lib.concatLists (mapAttrsToList (
        category: feeds:
          mapAttrsToList (_name: feed: {
            url = feed.url;
            inherit category;
          })
          feeds
      )
      cfg.feeds);
  in
    builtins.toJSON (builtins.listToAttrs (map (p: {
        name = p.url;
        value = p.category;
      })
      pairs));

  feedCategoryMapFile = pkgs.writeText "miniflux-feed-category-map.json" feedCategoryMap;

  syncScript = pkgs.writeShellApplication {
    name = "miniflux-sync-feeds";
    runtimeInputs = [pkgs.coreutils pkgs.curl pkgs.jq];
    text = builtins.readFile ./sync-feeds.sh;
  };
in {
  options.myOptions.miniflux = {
    enable = mkEnableOption "Miniflux RSS reader";

    adminCredentialsFile = mkOption {
      type = types.path;
      default = defaultCredentials;
      description = ''
        Path to a systemd EnvironmentFile containing ADMIN_USERNAME and
        ADMIN_PASSWORD. The Miniflux service and feed sync use the same file.
      '';
    };

    port = mkOption {
      type = types.port;
      default = 8070;
      description = "Port for Miniflux to listen on";
    };

    virtualHost = mkOption {
      type = types.str;
      default = "miniflux.localhost";
      description = "Virtual host for accessing Miniflux";
    };

    feeds = mkOption {
      type = types.attrsOf (types.attrsOf (types.submodule {
        options = {
          url = mkOption {
            type = types.str;
            description = "RSS feed URL";
          };
        };
      }));
      default = {};
      example = {
        News = {
          "Kagi UK" = {url = "https://kite.kagi.com/uk.xml";};
          "Kagi World" = {url = "https://kite.kagi.com/world.xml";};
        };
        Tech = {
          "Hacker News" = {url = "https://news.ycombinator.com/rss";};
        };
      };
      description = ''
        Declarative feed configuration organized by category.
        Feeds are synced to Miniflux on system activation.
      '';
    };

    syncFeeds = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to automatically sync feeds on system activation";
    };
  };

  config = mkIf cfg.enable {
    services.miniflux = {
      enable = true;
      adminCredentialsFile = cfg.adminCredentialsFile;
      config = {
        FETCHER_ALLOW_PRIVATE_NETWORKS = "1";
        LISTEN_ADDR = "127.0.0.1:${toString cfg.port}";
        BASE_URL = "http://${cfg.virtualHost}";
      };
    };

    services.caddy = {
      enable = true;
      virtualHosts."http://${cfg.virtualHost}" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:${toString cfg.port}
        '';
      };
      virtualHosts."http://:80" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:${toString cfg.port}
        '';
      };
    };

    networking.hosts."127.0.0.1" = [cfg.virtualHost];

    systemd.services.miniflux-sync-feeds = mkIf (cfg.syncFeeds && cfg.feeds != {}) {
      description = "Sync declarative feeds to Miniflux";
      after = ["miniflux.service" "network.target"];
      requires = ["miniflux.service"];
      wantedBy = ["multi-user.target"];

      environment = {
        MINIFLUX_URL = "http://127.0.0.1:${toString cfg.port}";
        OPML_FILE = toString opmlFile;
        FEED_CATEGORY_MAP = toString feedCategoryMapFile;
      };

      serviceConfig = {
        Type = "oneshot";
        EnvironmentFile = cfg.adminCredentialsFile;
        ExecStart = lib.getExe syncScript;
        RemainAfterExit = true;
      };
    };
  };
}
