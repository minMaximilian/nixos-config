{
  default = "ddg";
  force = true;
  engines = {
    "google" = {
      urls = [
        {
          template = "https://www.google.com/search?q={searchTerms}";
        }
      ];
      icon = "https://www.google.com/favicon.ico";
      definedAliases = ["@g"];
    };

    "ddg" = {
      urls = [
        {
          template = "https://duckduckgo.com/?q={searchTerms}";
        }
      ];
      icon = "https://duckduckgo.com/favicon.ico";
      definedAliases = ["@d"];
    };

    "Brave Search" = {
      urls = [
        {
          template = "https://search.brave.com/search?q={searchTerms}";
        }
      ];
      icon = "https://brave.com/favicon.ico";
      definedAliases = ["@b"];
    };

    "GitHub" = {
      urls = [
        {
          template = "https://github.com/search?q={searchTerms}";
        }
      ];
      icon = "https://github.com/favicon.ico";
      definedAliases = ["@gh"];
    };

    "youtube" = {
      urls = [
        {
          template = "https://www.youtube.com/results?search_query={searchTerms}";
        }
      ];
      icon = "https://www.youtube.com/favicon.ico";
      definedAliases = ["@yt"];
    };

    "Nix Packages" = {
      urls = [
        {
          template = "https://search.nixos.org/packages?channel=unstable&from=0&size=50&sort=relevance&type=packages&query={searchTerms}";
        }
      ];
      icon = "https://nixos.org/favicon.ico";
      definedAliases = ["@np"];
    };

    "Home Manager Options" = {
      urls = [
        {
          template = "https://mipmip.github.io/home-manager-option-search/?query={searchTerms}";
        }
      ];
      icon = "https://nixos.org/favicon.ico";
      definedAliases = ["@ho"];
    };

    "Sourcegraph" = {
      urls = [
        {
          template = "https://sourcegraph.com/search?q={searchTerms}&patternType=literal";
        }
      ];
      icon = "https://sourcegraph.com/favicon.ico";
      definedAliases = ["@sg"];
    };
  };
}
