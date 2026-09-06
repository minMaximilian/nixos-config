{lib}:
import ../modules/home/core/git-hooks/pre-commit.nix {
  inherit lib;
  systemFormatters = {
    ".*\\.py$" = [["black" "--quiet"]];
    ".*\\.missing$" = [["nonexistent-formatter-for-test"]];
  };
}
