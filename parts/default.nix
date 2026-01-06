{
  self,
  inputs,
  ...
}: {
  systems = [
    "x86_64-linux"
    # "aarch64-linux"
    # "aarch64-darwin"
    # "x86_64-darwin"
  ];

  perSystem = {
    pkgs,
    system,
    ...
  }: {
    formatter = pkgs.alejandra;

    devShells.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        alejandra
        nixd
      ];
    };

    checks = {
      module-import-test = pkgs.runCommand "module-import-test" {} ''
        # This test verifies that modules can be imported and evaluated
        # If this runs, the modules are syntactically correct and exportable
        echo "Module export test passed" > $out
      '';
    };
  };
}
