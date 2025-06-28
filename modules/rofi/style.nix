{config}: let
  inherit (config.colorScheme) palette;
in ''
  /**
   * Base16 Theme for Rofi
   * Streamlined version
   */

  * {
    foreground:              #${palette.base05};
    background:              #${palette.base00};
    lightbg:                 #${palette.base01};
    red:                     #${palette.base08};
    blue:                    #${palette.base0D};
    highlight:               #${palette.base0A};
    border-color:            #${palette.base0D};

    background-color:        @background;
    separatorcolor:          @foreground;

    /* States */
    selected-normal-foreground:  #${palette.base01};
    selected-normal-background:  #${palette.base0D};
    selected-active-foreground:  @background;
    selected-active-background:  @blue;
    selected-urgent-foreground:  @background;
    selected-urgent-background:  @red;

    normal-foreground:           @foreground;
    normal-background:           @background;

    active-foreground:           @blue;
    active-background:           @background;

    urgent-foreground:           @red;
    urgent-background:           @background;

    alternate-normal-foreground: @foreground;
    alternate-normal-background: @lightbg;
    alternate-active-foreground: @blue;
    alternate-active-background: @lightbg;
    alternate-urgent-foreground: @red;
    alternate-urgent-background: @lightbg;
  }

  window {
    transparency:   true;
    background-color: @background;
    text-color:     @foreground;
    border:         2px;
    border-color:   @border-color;
    border-radius:  10px;
    width:          35%;
    padding:        15px;
  }

  prompt {
    enabled:        true;
    padding:        10px;
    background-color: @lightbg;
    text-color:     @foreground;
    border-radius:  5px;
    font:           "JetBrainsMono Nerd Font 12";
  }

  textbox-prompt-colon {
    expand:         false;
    str:            ">";
    background-color: @lightbg;
    text-color:     @foreground;
    padding:        10px 0px 0px 5px;
  }

  entry {
    background-color: @lightbg;
    text-color:     @foreground;
    placeholder-color: @foreground;
    expand:         true;
    horizontal-align: 0;
    placeholder:    "Search...";
    padding:        10px;
    border-radius:  5px;
    margin:         0px 0px 0px 10px;
  }

  inputbar {
    children:       [ prompt, entry ];
    background-color: @background;
    text-color:     @foreground;
    expand:         false;
    border-radius:  0px;
    padding:        0px;
    margin:         0px 0px 15px 0px;
  }

  listview {
    background-color: @background;
    padding:        0px;
    columns:        1;
    lines:          8;
    spacing:        5px;
    cycle:          true;
    dynamic:        true;
    layout:         vertical;
    border:         0;
  }

  mainbox {
    background-color: @background;
    border:         0px;
    border-radius:  0px;
    padding:        15px;
  }

  element {
    background-color: @normal-background;
    text-color:     @normal-foreground;
    orientation:    horizontal;
    border-radius:  5px;
    padding:        8px;
  }

  element-icon {
    background-color: inherit;
    text-color:     inherit;
    horizontal-align: 0.5;
    vertical-align: 0.5;
    size:           24px;
    border:         0px;
  }

  element-text {
    background-color: inherit;
    text-color:     inherit;
    expand:         true;
    horizontal-align: 0;
    vertical-align: 0.5;
    margin:         0px 2.5px 0px 2.5px;
  }

  element.selected.normal {
    background-color: @selected-normal-background;
    text-color:     @selected-normal-foreground;
  }

  element.selected.urgent {
    background-color: @selected-urgent-background;
    text-color:     @selected-urgent-foreground;
  }

  element.selected.active {
    background-color: @selected-active-background;
    text-color:     @selected-active-foreground;
  }

  element.alternate.normal {
    background-color: @alternate-normal-background;
    text-color:     @alternate-normal-foreground;
  }

  element.alternate.urgent {
    background-color: @alternate-urgent-background;
    text-color:     @alternate-urgent-foreground;
  }

  element.alternate.active {
    background-color: @alternate-active-background;
    text-color:     @alternate-active-foreground;
  }

  /* Match highlighting */
  element .highlight {
    text-color: @highlight;
  }
''
