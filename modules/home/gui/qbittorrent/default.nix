{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption mkIf types;
  cfg = config.myOptions.qbittorrent;

  # Best public trackers from ngosang/trackerslist (updated 2026-02-11)
  defaultTrackers = [
    "http://tracker.opentrackr.org:1337/announce"
    "udp://open.demonii.com:1337/announce"
    "udp://open.stealth.si:80/announce"
    "udp://exodus.desync.com:6969/announce"
    "udp://zer0day.ch:1337/announce"
    "udp://wepzone.net:6969/announce"
    "udp://tracker.torrent.eu.org:451/announce"
    "udp://tracker.srv00.com:6969/announce"
    "udp://tracker.bittor.pw:1337/announce"
    "udp://tracker.alaskantf.com:6969/announce"
    "udp://tracker-udp.gbitt.info:80/announce"
    "udp://t.overflow.biz:6969/announce"
    "udp://opentracker.io:6969/announce"
    "udp://open.dstud.io:6969/announce"
    "udp://leet-tracker.moe:1337/announce"
    "udp://explodie.org:6969/announce"
    "https://tracker.zhuqiy.com:443/announce"
    "https://tracker.pmman.tech:443/announce"
    "https://tracker.moeblog.cn:443/announce"
    "https://tracker.iperson.xyz:443/announce"
  ];

  trackersString = lib.concatStringsSep "\\n" cfg.trackers;

  # Search plugins fetched from upstream at build time — no vendored .py files.
  # Sources: https://github.com/qbittorrent/search-plugins/wiki/Unofficial-search-plugins
  #
  # NOTE: Bitmagnet, Knaben, and kickasstorrents.ws do not have public
  # qBittorrent search plugins available. The user's list likely came from
  # Jackett/Prowlarr indexers. Use Jackett for those if needed.
  searchPlugins = {
    ## — Anime / Manga / Books —
    # Nyaa.si — anime, manga, music, light novels, software
    nyaasi = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/MadeOfMagicAndWires/qBit-plugins/master/engines/nyaasi.py";
      hash = "sha256-izjet9IthsPWQwDNWNVYECYOphuWsP1VLDdIIB3kTkY=";
    };

    ## — General Purpose —
    # 1337x — movies, tv, music, games, anime, software
    leetx = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/v1k45/1337x-qBittorrent-search-plugin/master/leetx.py";
      hash = "sha256-lLIrL8b+yBwf1/oiHMNEPaFW3c94a57NsM+UQ49tPXs=";
    };
    # TorrentGalaxy — movies, tv, games, music, anime, software
    torrentgalaxy = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/nindogo/qbtSearchScripts/master/torrentgalaxy.py";
      hash = "sha256-lEjL68JOvy219CLU4K4TkXuFEqgtRluiftrVggLdwy4=";
    };
    # ThePirateBay — general purpose (LightDestory)
    thepiratebay = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/LightDestory/qBittorrent-Search-Plugins/master/src/engines/thepiratebay.py";
      hash = "sha256-Co6D7q8VqmWnFIKNKO+bapkTnG4FYphnHUodXGp0N9U=";
    };
    # KickassTorrents (katcr.to) — general purpose
    kickasstorrents = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/LightDestory/qBittorrent-Search-Plugins/master/src/engines/kickasstorrents.py";
      hash = "sha256-s+n3FPBpNqkYWzpUvVim9CMNE9E3jYcBIoTylVv2jWk=";
    };
    # BitSearch — torrent meta-search (BurningMop, Jan 2026)
    bitsearch = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/BurningMop/qBittorrent-Search-Plugins/main/bitsearch.py";
      hash = "sha256-IbhW8C68woSXoCBTnoDTR9XfW24taZfULLX52QqyqJU=";
    };
    # SolidTorrents — privacy-friendly meta search
    solidtorrents = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/BurningMop/qBittorrent-Search-Plugins/refs/heads/main/solidtorrents.py";
      hash = "sha256-txRD/bZ/NxTHIvLveIbON225TV15G0f7Jnz7NVmx/6A=";
    };
    # TorrentDownload — general purpose aggregator
    torrentdownload = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/LightDestory/qBittorrent-Search-Plugins/master/src/engines/torrentdownload.py";
      hash = "sha256-M6apIwfjAg6c8pgEr1sGTb8QNsezg61wJzPEbyBpKAQ=";
    };

    ## — Specialised —
    # YTS — high-quality movie torrents
    yts = pkgs.fetchurl {
      url = "https://codeberg.org/lazulyra/qbit-plugins/raw/branch/main/yts/yts.py";
      hash = "sha256-VpihlTXG0Pcj7hiLY4AjX6kOMxgXdl7XknjBOSTnTiE=";
    };
    # EZTV — TV shows (official qBittorrent plugin)
    eztv = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/qbittorrent/search-plugins/master/nova3/engines/eztv.py";
      hash = "sha256-adRW9Ufh7ZLXuatTCIfmut+BgZAtr9nB/SXkaoDGf+g=";
    };
    # LimeTorrents — general purpose (LightDestory, Jun 2025)
    limetorrents = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/LightDestory/qBittorrent-Search-Plugins/master/src/engines/limetorrents.py";
      hash = "sha256-1aaN2+dE10MsXcH+di4KbBME5YQVSGr4grIyFKdY22Q=";
    };
    # AudioBook Bay — ebooks and audiobooks
    audiobookbay = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/nklido/qBittorrent_search_engines/master/engines/audiobookbay.py";
      hash = "sha256-qBXBbaVw5YseuiEdS9H77oNd3c2ef5oaxj177L9By14=";
    };
  };
in {
  options.myOptions.qbittorrent = {
    enable = mkEnableOption "qBittorrent torrent client";

    trackers = mkOption {
      type = types.listOf types.str;
      default = defaultTrackers;
      description = "List of tracker URLs to automatically add to new downloads.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      qbittorrent
      python3 # required for qBittorrent search engine plugins
    ];

    # Preconfigure qBittorrent to automatically add trackers to new downloads.
    # Won't overwrite if user has already configured via GUI.
    xdg.configFile."qBittorrent/qBittorrent.conf" = {
      force = true;
      text = ''
        [LegalNotice]
        Accepted=true

        [BitTorrent]
        Session\AddTrackersEnabled=true
        Session\AdditionalTrackers=${trackersString}

        [Preferences]
        General\Locale=en
        Search\SearchEnabled=true
        Downloads\SavePath=/home/${config.myOptions.vars.username}/Downloads
        Downloads\PreAllocation=true
        Connection\UPnP=true
        Bittorrent\DHT=true
        Bittorrent\PeX=true
        Bittorrent\LSD=true
        Bittorrent\Encryption=1
        General\CloseToTray=true
        General\MinimizeToTray=true
      '';
    };

    xdg.configFile."qBittorrent/qBittorrent-data.conf" = {
      force = true;
      text = ''
        [Meta]
        MigrationVersion=6
      '';
    };

    # Search engine plugins — fetched from GitHub at build time.
    # Enable the Search tab in qBittorrent via View → Search Engine.
    xdg.dataFile = lib.mapAttrs' (name: src:
      lib.nameValuePair "qBittorrent/nova3/engines/${name}.py" {source = src;})
    searchPlugins;
  };
}
