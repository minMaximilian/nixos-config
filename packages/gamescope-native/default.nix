{
  writeShellScriptBin,
  gamescope,
  width,
  height,
  refreshRate,
}:
writeShellScriptBin "gamescope-native" ''
  exec ${gamescope}/bin/gamescope \
    -W ${toString width} -H ${toString height} \
    -w ${toString width} -h ${toString height} \
    -r ${toString refreshRate} \
    -f -b \
    --force-grab-cursor \
    -- "$@"
''
