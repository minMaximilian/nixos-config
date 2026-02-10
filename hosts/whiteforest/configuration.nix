{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  myOptions.vars.withGui = true;
  myOptions.amdgpu.enable = true;
  myOptions.logitech.enable = true;
  myOptions.deadlockModManager.enable = true;
  myOptions.teamspeak.enable = true;
  myOptions.memory.enable = true;
  myOptions.fish.enable = true;
  myOptions.neovim.enable = true;
  myOptions.miniflux.enable = true;
  myOptions.miniflux.feeds = {
    News = {
      "Kagi UK" = {url = "https://kite.kagi.com/uk.xml";};
      "Kagi USA" = {url = "https://kite.kagi.com/usa.xml";};
      "Kagi Ireland" = {url = "https://kite.kagi.com/ireland.xml";};
      "Lobsters" = {url = "https://lobste.rs/rss";};
    };
    Podcasts = {
      "Lemonade Stand" = {url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCwVevVbti5Uuxj6Mkl5NHRA";};
    };
    "Engineering Blogs" = {
      "Sean Goedecke" = {url = "https://www.seangoedecke.com/rss.xml";};
    };
  };
  myOptions.miniflux.quivrs = {
    enable = true;
    minifluxApiKeyFile = "/home/${config.myOptions.vars.username}/.config/miniflux/api-key.txt";
    feeds = {
      News = {
        kagi_uk = {
          url_rss = "https://kite.kagi.com/uk.xml";
          original_title = true;
          original_content = true;
        };
        kagi_usa = {
          url_rss = "https://kite.kagi.com/usa.xml";
          original_title = true;
          original_content = true;
        };
        kagi_ireland = {
          url_rss = "https://kite.kagi.com/ireland.xml";
          original_title = true;
          original_content = true;
        };
        lobsters = {
          url_rss = "https://lobste.rs/rss";
        };
      };
      Podcasts = {
        LemonadeStandPodcast.source = "Youtube";
      };
    };
  };

  myOptions.hyprland.monitors = [
    "DP-3, 3440x1440@144, 2560x0, 1"
    "HDMI-A-1, 2560x1440@60, 0x0, 1"
  ];

  networking.hostName = "whiteforest";

  services.resolved.enable = true;

  environment.systemPackages = with pkgs; [
    code-cursor
  ];

  system.stateVersion = "25.11";
}
