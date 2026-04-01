{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption mkIf types concatStringsSep mapAttrsToList;
  cfg = config.myOptions.miniflux;

  defaultCredentials = pkgs.writeText "miniflux-admin-credentials" ''
    ADMIN_USERNAME=admin
    ADMIN_PASSWORD=123456
  '';

  feedToOpml = name: feed: ''<outline text="${name}" title="${name}" type="rss" xmlUrl="${feed.url}" />'';

  categoryToOpml = category: feeds: ''
    <outline text="${category}" title="${category}">
      ${concatStringsSep "\n      " (mapAttrsToList feedToOpml feeds)}
    </outline>'';

  opmlContent = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <opml version="2.0">
      <head>
        <title>Miniflux Feeds</title>
      </head>
      <body>
        ${concatStringsSep "\n    " (mapAttrsToList categoryToOpml cfg.feeds)}
      </body>
    </opml>
  '';

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

  syncScript = pkgs.writeShellScript "miniflux-sync-feeds" ''
    set -euo pipefail

    MINIFLUX_URL="http://127.0.0.1:${toString cfg.port}"
    OPML_FILE="${opmlFile}"
    MAX_RETRIES=30
    RETRY_DELAY=2
    JQ="${pkgs.jq}/bin/jq"

    # Wait for miniflux to be ready
    for i in $(seq 1 $MAX_RETRIES); do
      if ${pkgs.curl}/bin/curl -sf "$MINIFLUX_URL/healthcheck" > /dev/null 2>&1; then
        echo "Miniflux is ready"
        break
      fi
      if [ $i -eq $MAX_RETRIES ]; then
        echo "Miniflux not ready after $MAX_RETRIES attempts, giving up"
        exit 1
      fi
      echo "Waiting for miniflux... (attempt $i/$MAX_RETRIES)"
      sleep $RETRY_DELAY
    done

    # Read credentials
    ADMIN_USERNAME=$(grep ADMIN_USERNAME ${cfg.adminCredentialsFile} | cut -d= -f2)
    ADMIN_PASSWORD=$(grep ADMIN_PASSWORD ${cfg.adminCredentialsFile} | cut -d= -f2)

    # Import OPML via API
    echo "Importing feeds from OPML..."
    RESPONSE=$(${pkgs.curl}/bin/curl -sf -X POST \
      -u "$ADMIN_USERNAME:$ADMIN_PASSWORD" \
      -H "Content-Type: application/xml" \
      --data-binary @"$OPML_FILE" \
      "$MINIFLUX_URL/v1/import" 2>&1) || {
        echo "OPML import request failed: $RESPONSE"
        exit 1
      }

    echo "Feed import complete: $RESPONSE"

    # Enforce correct categories for existing feeds
    echo "Enforcing feed categories..."
    FEED_CATEGORY_MAP="${feedCategoryMapFile}"

    # Get all categories and build a name->id map
    CATEGORIES=$(${pkgs.curl}/bin/curl -sf \
      -u "$ADMIN_USERNAME:$ADMIN_PASSWORD" \
      "$MINIFLUX_URL/v1/categories")

    # Get all feeds
    FEEDS=$(${pkgs.curl}/bin/curl -sf \
      -u "$ADMIN_USERNAME:$ADMIN_PASSWORD" \
      "$MINIFLUX_URL/v1/feeds")

    # For each feed, check if its category matches the declared config
    echo "$FEEDS" | $JQ -c '.[]' | while read -r feed; do
      FEED_ID=$(echo "$feed" | $JQ -r '.id')
      FEED_URL=$(echo "$feed" | $JQ -r '.feed_url')
      CURRENT_CATEGORY=$(echo "$feed" | $JQ -r '.category.title')

      # Look up the desired category for this feed URL
      DESIRED_CATEGORY=$(cat "$FEED_CATEGORY_MAP" | $JQ -r --arg url "$FEED_URL" '.[$url] // empty')

      if [ -n "$DESIRED_CATEGORY" ] && [ "$DESIRED_CATEGORY" != "$CURRENT_CATEGORY" ]; then
        # Find the category ID for the desired category
        CATEGORY_ID=$(echo "$CATEGORIES" | $JQ -r --arg title "$DESIRED_CATEGORY" '.[] | select(.title == $title) | .id')

        if [ -n "$CATEGORY_ID" ]; then
          echo "Moving feed '$FEED_URL' from '$CURRENT_CATEGORY' to '$DESIRED_CATEGORY' (category_id=$CATEGORY_ID)"
          ${pkgs.curl}/bin/curl -sf -X PUT \
            -u "$ADMIN_USERNAME:$ADMIN_PASSWORD" \
            -H "Content-Type: application/json" \
            -d "{\"category_id\": $CATEGORY_ID}" \
            "$MINIFLUX_URL/v1/feeds/$FEED_ID" > /dev/null
        else
          echo "Warning: Category '$DESIRED_CATEGORY' not found, skipping feed '$FEED_URL'"
        fi
      fi
    done

    echo "Feed sync complete"
  '';
in {
  options.myOptions.miniflux = {
    enable = mkEnableOption "Miniflux RSS reader";

    adminCredentialsFile = mkOption {
      type = types.path;
      default = defaultCredentials;
      description = ''
        Path to file containing admin credentials.
        File format: ADMIN_USERNAME=user\nADMIN_PASSWORD=123456
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

      serviceConfig = {
        Type = "oneshot";
        ExecStart = syncScript;
        RemainAfterExit = true;
      };
    };
  };
}
