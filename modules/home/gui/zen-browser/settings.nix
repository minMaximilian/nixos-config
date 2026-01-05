{lib}: let
  inherit (lib) mkMerge;
in
  mkMerge [
    {
      "extensions.autoDisableScopes" = 0;

      "browser.startup.homepage" = "about:home";
      "browser.search.region" = "US";
      "browser.search.isUS" = true;
      "distribution.searchplugins.defaultLocale" = "en-US";
      "general.useragent.locale" = "en-US";
      "browser.bookmarks.showMobileBookmarks" = true;
      "browser.newtabpage.pinned" = [];
      "browser.startup.page" = 3;
      "browser.newtabpage.enabled" = true;

      "datareporting.policy.dataSubmissionEnable" = false;
      "datareporting.healthreport.uploadEnabled" = false;
      "toolkit.telemetry.unified" = false;
      "toolkit.telemetry.enabled" = false;
      "toolkit.telemetry.server" = "data:,";
      "toolkit.telemetry.archive.enabled" = false;
      "toolkit.telemetry.newProfilePing.enabled" = false;
      "toolkit.telemetry.updatePing.enabled" = false;
      "toolkit.telemetry.bhrPing.enabled" = false;
      "toolkit.telemetry.firstShutdownPing.enabled" = false;
      "toolkit.telemetry.coverage.opt-out" = true;
      "toolkit.coverage.opt-out" = true;
      "toolkit.coverage.endpoint.base" = "";
      "browser.ping-centre.telemetry" = false;
      "browser.newtabpage.activity-stream.feeds.telemetry" = false;
      "browser.newtabpage.activity-stream.telemetry" = false;

      "extensions.pocket.enabled" = false;
      "extensions.pocket.api" = "";
      "extensions.pocket.oAuthConsumerKey" = "";
      "extensions.pocket.showHome" = false;
      "extensions.pocket.site" = "";

      "network.prefetch-next" = false;
      "network.dns.disablePrefetch" = true;
      "network.predictor.enabled" = false;

      "pdfjs.enableScripting" = false;

      "security.ssl.require_safe_negotiation" = true;
      "security.tls.enable_0rtt_data" = false;

      "browser.fixup.alternate.enabled" = false;
      "browser.urlbar.trimURLs" = false;
      "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
      "browser.urlbar.suggest.quicksuggest.sponsored" = false;

      "general.smoothScroll" = true;
      "general.smoothScroll.currentVelocityWeighting" = "0.1";
      "general.smoothScroll.mouseWheel.durationMaxMS" = 250;
      "general.smoothScroll.mouseWheel.durationMinMS" = 125;
      "general.smoothScroll.stopDecelerationWeighting" = "0.7";
      "mousewheel.min_line_scroll_amount" = 20;
      "apz.overscroll.enabled" = true;
      "general.smoothScroll.msdPhysics.enabled" = true;
      "general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS" = 12;
      "general.smoothScroll.msdPhysics.motionBeginSpringConstant" = 600;
      "general.smoothScroll.msdPhysics.regularSpringConstant" = 650;
      "general.smoothScroll.msdPhysics.slowdownMinDeltaMS" = 25;
      "general.smoothScroll.msdPhysics.slowdownMinDeltaRatio" = 2.0;
      "general.smoothScroll.msdPhysics.slowdownSpringConstant" = 250;
      "mousewheel.system_scroll_override.horizontal.factor" = 200;
      "mousewheel.system_scroll_override.vertical.factor" = 200;
      "mousewheel.system_scroll_override_on_root_content.enabled" = true;
      "mousewheel.system_scroll_override.enabled" = true;
      "toolkit.scrollbox.horizontalScrollDistance" = 6;
      "toolkit.scrollbox.verticalScrollDistance" = 2;

      "privacy.donottrackheader.enabled" = true;
      "privacy.trackingprotection.enabled" = true;
      "privacy.trackingprotection.socialtracking.enabled" = true;
      "privacy.partition.network_state.ocsp_cache" = true;
      "privacy.userContext.enabled" = true;
      "privacy.userContext.ui.enabled" = true;

      "browser.download.useDownloadDir" = false;
      "browser.download.always_ask_before_handling_new_types" = true;
      "browser.download.manager.addToRecentDocs" = false;

      "permissions.default.geo" = 2;
      "permissions.default.camera" = 2;
      "permissions.default.microphone" = 2;
      "permissions.default.desktop-notification" = 2;
      "permissions.default.shortcuts" = 2;
      "permissions.default.xr" = 2;

      "browser.compactmode.show" = true;
      "browser.display.focus_ring_on_anything" = true;
      "browser.display.focus_ring_style" = 0;
      "browser.display.focus_ring_width" = 0;

      "gnomeTheme.hideSingleTab" = true;
      "gnomeTheme.bookmarksToolbarUnderTabs" = true;
      "gnomeTheme.hideWebrtcIndicator" = true;
      "gnomeTheme.systemIcons" = true;

      "browser.gnome-search-provider.enabled" = true;
      "browser.tabs.drawInTitlebar" = true;
      "widget.gtk.rounded-bottom-corners.enabled" = true;
    }
  ]
