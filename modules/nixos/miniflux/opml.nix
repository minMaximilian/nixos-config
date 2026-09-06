{lib}: feeds: let
  inherit (lib) concatStringsSep mapAttrsToList escapeXML;
  feedToOpml = name: feed: ''<outline text="${escapeXML name}" title="${escapeXML name}" type="rss" xmlUrl="${escapeXML feed.url}" />'';

  categoryToOpml = category: feeds: ''
    <outline text="${escapeXML category}" title="${escapeXML category}">
      ${concatStringsSep "\n      " (mapAttrsToList feedToOpml feeds)}
    </outline>'';
in ''
  <?xml version="1.0" encoding="UTF-8"?>
  <opml version="2.0">
    <head>
      <title>Miniflux Feeds</title>
    </head>
    <body>
      ${concatStringsSep "\n    " (mapAttrsToList categoryToOpml feeds)}
    </body>
  </opml>
''
