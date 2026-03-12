{
  config,
  pkgs,
  lib,
  inputs ? {},
  ...
}: let
  inherit (lib) mkEnableOption mkOption mkIf types;
  cfg = config.myOptions.intellij;
  hasJetbrainsPlugins = inputs ? nix-jetbrains-plugins;
  system = pkgs.stdenv.hostPlatform.system;
  ideaPlugins =
    if hasJetbrainsPlugins
    then inputs.nix-jetbrains-plugins.plugins.${system}.idea-oss.${cfg.ideaVersion}
    else {};
  resolvedPlugins = map (id: ideaPlugins.${id}) cfg.plugins;
in {
  options.myOptions.intellij = {
    enable = mkEnableOption "IntelliJ IDEA for Minecraft development";

    package = mkOption {
      type = types.package;
      default = pkgs.jetbrains.idea-oss;
      description = "The IntelliJ IDEA package to use.";
    };

    ideaVersion = mkOption {
      type = types.str;
      default = pkgs.jetbrains.idea-oss.version;
      description = ''
        The IDEA version to match plugins against.
        Must match a version in nix-jetbrains-plugins.
      '';
    };

    configDir = mkOption {
      type = types.str;
      default = "IdeaIC2025.3";
      description = ''
        The JetBrains config directory name under ~/.config/JetBrains/.
        For idea-oss/community: IdeaIC<version>
        For idea (ultimate/unified): IntelliJIdea<version>
      '';
    };

    plugins = mkOption {
      type = types.listOf types.str;
      default = [
        "IdeaVIM"
        "com.demonwav.minecraft-dev"
        "google-java-format"
      ];
      description = ''
        List of JetBrains Marketplace plugin IDs to install.
        Find IDs at the bottom of plugin pages on https://plugins.jetbrains.com
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      if hasJetbrainsPlugins
      then [(pkgs.jetbrains.plugins.addPlugins cfg.package resolvedPlugins)]
      else [cfg.package];

    home.file = {
      ".local/share/java/temurin-17".source = pkgs.temurin-bin-17;
      ".local/share/java/temurin-21".source = pkgs.temurin-bin-21;
      ".ideavimrc".source = ./ideavimrc;
      ".config/JetBrains/${cfg.configDir}/codestyles/GoogleStyle.xml".source = ./codestyle.xml;
      ".config/JetBrains/${cfg.configDir}/options/code.style.schemes.xml".text = ''
        <application>
          <component name="CodeStyleSchemeSettings">
            <option name="PREFERRED_PROJECT_CODE_STYLE" value="GoogleStyle" />
            <option name="CURRENT_SCHEME_NAME" value="GoogleStyle" />
          </component>
        </application>
      '';
      ".config/JetBrains/${cfg.configDir}/options/actions-on-save.xml".text = ''
        <application>
          <component name="ActionsOnSaveManager">
            <action id="ReformatCodeOnSave" enabled="true" />
            <action id="OptimizeImportsOnSave" enabled="true" />
          </component>
        </application>
      '';
      ".config/JetBrains/${cfg.configDir}/options/editor.xml".text = ''
        <application>
          <component name="CodeInsightSettings">
            <option name="ADD_UNAMBIGIOUS_IMPORTS_ON_THE_FLY" value="true" />
            <option name="OPTIMIZE_IMPORTS_ON_THE_FLY" value="true" />
          </component>
        </application>
      '';
      ".config/JetBrains/${cfg.configDir}/options/google-java-format.xml".text = ''
        <application>
          <component name="GoogleJavaFormatSettings">
            <option name="enabled" value="true" />
          </component>
        </application>
      '';
      ".config/JetBrains/${cfg.configDir}/idea64.vmoptions".text = ''
        --add-exports=jdk.compiler/com.sun.tools.javac.api=ALL-UNNAMED
        --add-exports=jdk.compiler/com.sun.tools.javac.code=ALL-UNNAMED
        --add-exports=jdk.compiler/com.sun.tools.javac.file=ALL-UNNAMED
        --add-exports=jdk.compiler/com.sun.tools.javac.parser=ALL-UNNAMED
        --add-exports=jdk.compiler/com.sun.tools.javac.tree=ALL-UNNAMED
        --add-exports=jdk.compiler/com.sun.tools.javac.util=ALL-UNNAMED
      '';
    };
  };
}
