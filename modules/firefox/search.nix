{
  default = "DuckDuckGo";
  force = true;
  engines = {
    "Google" = {
      urls = [
        {
          template = "https://www.google.com/search?q={searchTerms}";
        }
      ];
      iconUpdateURL = "https://www.google.com/favicon.ico";
      definedAliases = ["@g"];
    };

    "DuckDuckGo" = {
      urls = [
        {
          template = "https://duckduckgo.com/?q={searchTerms}";
        }
      ];
      iconUpdateURL = "https://duckduckgo.com/favicon.ico";
      definedAliases = ["@d"];
    };

    "Brave Search" = {
      urls = [
        {
          template = "https://search.brave.com/search?q={searchTerms}";
        }
      ];
      iconUpdateURL = "https://brave.com/favicon.ico";
      definedAliases = ["@b"];
    };

    "GitHub" = {
      urls = [
        {
          template = "https://github.com/search?q={searchTerms}";
        }
      ];
      iconUpdateURL = "https://github.com/favicon.ico";
      definedAliases = ["@gh"];
    };

    "YouTube" = {
      urls = [
        {
          template = "https://www.youtube.com/results?search_query={searchTerms}";
        }
      ];
      iconUpdateURL = "https://www.youtube.com/favicon.ico";
      definedAliases = ["@yt"];
    };

    "Nix Packages" = {
      urls = [
        {
          template = "https://search.nixos.org/packages?channel=unstable&from=0&size=50&sort=relevance&type=packages&query={searchTerms}";
        }
      ];
      iconUpdateURL = "https://nixos.org/favicon.ico";
      definedAliases = ["@np"];
    };

    "Home Manager Options" = {
      urls = [
        {
          template = "https://mipmip.github.io/home-manager-option-search/?query={searchTerms}";
        }
      ];
      iconUpdateURL = "https://nixos.org/favicon.ico";
      definedAliases = ["@ho"];
    };

    "Sourcegraph" = {
      urls = [
        {
          template = "https://sourcegraph.com/search?q={searchTerms}&patternType=literal";
        }
      ];
      iconUpdateURL = "https://sourcegraph.com/favicon.ico";
      definedAliases = ["@sg"];
    };
  };
}
