{palette}: {
  animations = {
    enabled = true;
    bezier = ["myBezier, 0.05, 0.9, 0.1, 1.05"];
    animation = [
      "windows, 1, 7, myBezier"
      "windowsOut, 1, 7, default, popin 80%"
      "windowsMove, 1, 2, default, popin 80%"
      "border, 1, 10, default"
      "borderangle, 1, 8, default"
      "fade, 1, 7, default"
      "workspaces, 1, 6, default"
    ];
  };

  decoration = {
    rounding = 0;
    active_opacity = 1.0;
    inactive_opacity = 0.95;
    dim_inactive = false;
    dim_strength = 0.7;

    blur = {
      enabled = true;
      size = 5;
      passes = 3;
      vibrancy = 0.4;
      new_optimizations = true;
      ignore_opacity = true;
      xray = true;
      special = true;
    };

    shadow = {
      enabled = true;
      range = 8;
      render_power = 2;
      offset = "0 0";
      color = "rgb(${palette.base00})";
    };
  };

  general = {
    gaps_in = 3;
    gaps_out = 3;
    border_size = 2;
    "col.active_border" = "$active $groupActive 45deg";
    "col.inactive_border" = "$inactive";
    layout = "dwindle";
  };

  layerrule = [
    "blur, notifications"
    "blur, launcher"
    "blur, lockscreen"
    "ignorealpha 0.69, notifications"
    "ignorealpha 0.69, launcher"
    "ignorealpha 0.69, lockscreen"
  ];
}
