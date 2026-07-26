{
  config,
  lib,
  ...
}: let
  cfg = config.myOptions.agentRules;

  instructions = ''
    # Global Agent Instructions

    ## Karpathy Coding Guidelines

    ### Think Before Coding

    - State assumptions and surface meaningful tradeoffs.
    - Ask when ambiguity cannot be resolved from the environment.
    - Prefer the simpler viable approach.

    ### Surgical Changes

    - Touch only lines required by the task.
    - Match existing style and do not refactor unrelated code.
    - Remove only dead code introduced by the current change.

    ### Goal-Driven Execution

    - Define observable success criteria before implementation.
    - Verify changes with focused tests and the repository's required checks.
    - Continue until the requested behavior is verified or a concrete blocker is reported.

    ## Selective HTML Artifacts

    Use normal text or Markdown for short answers, status updates, and compact technical
    explanations. Create a self-contained HTML artifact when visual structure or
    interaction materially improves a long report, comparison, architecture explanation,
    prototype, dashboard, presentation, or one-off editor.

    - Do not turn every response into HTML.
    - Prefer semantic HTML, readable typography, responsive layout, and minimal dependencies.
    - Use inline CSS and JavaScript unless the task requires a larger application.
    - Interactive editors must provide an explicit export, download, or copy-back action.
    - Write temporary artifacts under `/tmp/agent-artifacts/` unless the user asks for a
      repository file.
    - End with a concise chat summary and the artifact path instead of duplicating its content.

    ## Impeccable Frontend Design

    For frontend design, redesign, critique, audit, polish, typography, color,
    layout, motion, accessibility, or UI hardening work, use Impeccable when it is
    installed.

    - Impeccable is installed declaratively by this flake for Codex, Amp, and Pi.
    - Update it by bumping the `impeccable` flake input.
    - Start each project with `/impeccable init`.
    - Use `/impeccable audit`, `/impeccable critique`, and `/impeccable polish`
      for UI quality passes before shipping.
  '';
in {
  options.myOptions.agentRules.enable =
    lib.mkEnableOption "shared global instructions for coding agents";

  config = lib.mkIf cfg.enable {
    home.file.".codex/AGENTS.md".text = instructions;
  };
}
