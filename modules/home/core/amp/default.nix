{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.myOptions.amp;
in {
  options.myOptions.amp = {
    enable = mkEnableOption "amp CLI tool";
  };

  config = mkIf cfg.enable {
    home.sessionPath = ["$HOME/.amp/bin"];

    home.packages = with pkgs; [
      amp-cli
    ];

    xdg.configFile."amp/settings.json".text = builtins.toJSON {
      "amp.gauge" = "tokens";
    };

    xdg.configFile."amp/plugins/impeccable.ts".text = ''
      import type { PluginAPI } from '@ampcode/plugin'

      export default function (amp: PluginAPI) {
        amp.registerCommand(
          'impeccable',
          {
            title: '/impeccable',
            category: 'design',
            description: 'Use Impeccable for frontend design work.',
          },
          async (ctx) => {
            const args = (await ctx.ui.input({
              title: '/impeccable',
              helpText: 'Optional arguments',
              submitButtonText: 'Run',
            }))?.trim()

            const message = args
              ? 'Use the impeccable skill. Treat this as the /impeccable arguments: ' + args
              : 'Use the impeccable skill.'
            await ctx.thread?.append([{ type: 'user-message', content: message }])
          },
        )
      }
    '';
  };
}
