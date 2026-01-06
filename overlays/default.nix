final: prev: {
  amp = prev.writeShellScriptBin "amp" ''
    export NPM_CONFIG_YES=true
    exec ${prev.nodejs_20}/bin/npx -y @sourcegraph/amp@latest "$@"
  '';
}
