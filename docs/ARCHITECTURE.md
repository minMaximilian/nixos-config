# Architecture audit and refactor

Audited against checkpoint `d685a4b8e5b4b688366fa4baaf745941ba26a40a`.
The checkpoint was pushed to `origin/master` before refactoring; implementation
continues on `master`. The scope includes all 119 tracked checkpoint entries,
not only Nix files. Generated/binary artifacts are identified separately below.

## Decision

Use explicit native NixOS/Home Manager modules, small personal profiles, and
separate host/user/package ownership. No new module framework, discovery engine,
host-spec schema, OS abstraction layer or deployment tool.

Observable success criteria: both existing hosts evaluate; selected package
versions and effective settings remain stable except the listed fixes; reusable
modules evaluate independently on Linux and Darwin; a headless composition does
not import the desktop; regression checks exercise the changed scripts; no live
system or user data is modified.

## Comparison with other configurations

These are architectural references, not compatibility promises or templates to
copy wholesale. Repository layouts were inspected during the audit; conclusions
in the last column are our design judgments.

| Reference | Relevant pattern | Applied here / intentionally omitted |
| --- | --- | --- |
| [hlissner/dotfiles](https://github.com/hlissner/dotfiles) | Distinct hosts, modules, package recipes, library and management tooling | Adopt concern boundaries. Do not copy its custom constructor/discovery machinery or `hey` command suite. Its own README warns that it is a personal experiment, not a community framework. |
| [mitchellh/nixos-config](https://github.com/mitchellh/nixos-config) | Machine configurations, separate user system/home settings, small system constructor | Adopt explicit machine/user ownership. No speculative constructor flags for operating systems not configured here. |
| [EmergentMind/nix-config](https://github.com/EmergentMind/nix-config/tree/dev) | Common/core versus optional configuration across multiple hosts and users | Adopt explicit base/optional composition. Its larger fleet's host-spec infrastructure is unnecessary for these two hosts. |
| [Misterio77/Foundry](https://github.com/Misterio77/Foundry) | Separate concrete configurations, reusable modules, packages and overlays | Adopt the distinction between instances and reusable features. Do not add its broader monorepo/Hydra infrastructure. |
| [viperML/dotfiles](https://github.com/viperML/dotfiles) | Directly selected configuration and package-oriented reuse, with different input/home-management tooling | Favor direct imports and package recipes. Do not migrate this working Home Manager flake to another toolchain. |

The native [module system](https://nix.dev/tutorials/module-system/deep-dive.html)
already provides composition, priorities and typed options; standard
[`callPackage`](https://nix.dev/tutorials/callpackage.html) handles package
dependencies. A second abstraction layer would duplicate those mechanisms.

## Ownership and dependency direction

```text
flake inputs / flake-parts outputs
└── hosts/default.nix (native nixosSystem constructor)
    └── hosts/<host>/configuration.nix
        ├── hardware, storage, host services
        ├── profiles/nixos/{base,workstation,gaming}.nix
        │   └── focused system modules
        ├── users/max/nixos.nix (account + sole HM integration)
        │   └── users/max/home.nix (identity + personal base)
        └── hosts/<host>/home.nix (displays + personal HM profiles)
            └── focused Home Manager modules

packages/default.nix → lazy local package selections → package recipes
lib/minecraft-libraries.nix → existing IDE, launcher and shell consumers
modules/home/exports.nix → six independently usable Home Manager modules
```

Profiles select features and package-only applications. Modules configure a
single feature; they do not select a user's desktop by inspecting global vars.
Hosts own monitor assignments and gamescope dimensions even where both current
hosts happen to use the same values. User group memberships, Git identity, SSH
hosts and password policy belong to `users/max/`.

`localPackages` is a private, lazily evaluated package set injected by personal
composition. It is not a new public API and portable exports do not require it.
Package recipes preserve existing versions, hashes, patches and wrappers. The
Vesktop extraction deliberately retains its native `.override` interface because
Nixcord uses it. Only genuinely repeated Minecraft library selection is shared;
the callers retain their different JDK, udev and environment requirements.

## Findings and implemented changes

| Finding | Resolution |
| --- | --- |
| Automatic export/import discovery made filesystem layout part of the API and activated unrelated concerns | Explicit host/profile imports and six-entry export manifest; removed aggregate roots and dead library entry point |
| System modules wrote Home Manager settings for a globally selected username | One user integration owner; desktop and application configuration moved to HM profiles/hosts |
| Global vars mixed identity, UI selection, host monitors and palette choices | Native user/home options, explicit profiles and local theme values |
| Many modules only wrapped a single package or native boolean | Grouped package selections/native options in profiles; retained feature modules with real configuration |
| Inline derivations obscured application policy | Extracted local recipes without version/input updates |
| Java link and Minecraft runtime definitions had multiple owners | One owner per link and one small library-list helper |
| Editor settings could not be selected independently of the Linux IDE/desktop | Six opt-in portable exports; IdeaVim separated from IntelliJ; Neovim debug/Godot opt-in; absent nixCats input does not declare unknown options |
| Large Neovim startup file mixed concerns | Five ordered Lua modules: core, languages, completion, UI and debug; same effective mappings |
| Git formatter failures could pass; whole-file re-staging could capture deliberately unstaged edits | Abort on formatter failure; preflight every staged path before touching any file; NUL-safe path regression test |
| Hook ownership and documentation disagreed | Hook-owned formatter/Fish modules and corrected installation/skip semantics |
| Miniflux XML interpolation and credential parsing were fragile | Native XML escaping; service EnvironmentFile supplies credentials; tested equals, quotes and spaces |
| Password migration default-user handling and writes were unsafe | Validated destinations/users, restrictive permissions, atomic no-clobber writes and fake-shadow tests |
| Persistence mixed generic engine, physical storage and personal inventory | Three explicit owners; original inventory preserved plus qBittorrent mutable state |
| Duplicate Hyprland Alt-H actions / redundant Solaar launches | Preserve window-navigation Alt-H and qpwgraph Alt-Q; sole Solaar launch belongs to Whiteforest |
| IdeaVim Ctrl-K ParameterInfo mapping was overwritten later | Remove shadowed definition; preserve effective window-navigation mapping |
| Temporary OpenLDAP workaround never expired | Apply only to 2.6.13; other versions unchanged, with [upstream issue](https://github.com/NixOS/nixpkgs/issues/514113) |
| Logs, bytecode and build-result symlink tracked as source | Ignore rules added; index cleanup remains pending because Git metadata is read-only |

The script and binding corrections above are intentional exceptions to a
structure-only diff. No package upgrades, visual redesign, input updates,
credential rotation or service-exposure changes are included.

## Work MacBook reuse

Home Manager supports both standalone Darwin and nix-darwin integration.
An actual Mac host can use either; no nix-darwin input or dummy host is needed
before that machine exists.
[Home Manager installation modes](https://nix-community.github.io/home-manager/installation.html).

| Export | Required extra input when enabled | Scope |
| --- | --- | --- |
| `neovim` | `inputs.nixCats` | Shared editor/LSP/plugins; debug and Godot default off |
| `ideavim` | None | Shared .ideavimrc, independent of installing IntelliJ |
| `git` | None | Git behavior, no personal identity and no automatic hooks |
| `git-hooks` | None | Formatting templates/tools; Fish helpers only when Fish is enabled |
| `fish` | None | Shell configuration |
| `zellij` | None | Multiplexer configuration and bindings |

All six `myOptions.<name>.enable` switches default to false.
Optional Neovim nightly/ZLS inputs and Stylix integration remain optional.
Personal base/development/desktop profiles are **not** portable exports.

For a separate work flake, import this repository as source. A
[`flake = false` input](https://nix.dev/manual/nix/2.34/command-ref/new-cli/nix3-flake.html)
avoids evaluating this personal root flake and its absolute local RSS input:

```nix
{
  inputs = {
    personal = {
      url = "github:minMaximilian/nixos-config";
      flake = false;
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
  };

  outputs = { personal, nixpkgs, home-manager, nixCats, ... }: let
    shared = import (personal + "/modules/home/exports.nix");
  in {
    homeConfigurations.work = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs { system = "aarch64-darwin"; };
      extraSpecialArgs.inputs = { inherit nixCats; };
      modules = [
        shared.neovim
        shared.ideavim
        shared.git
        shared.fish
        shared.zellij
        {
          home.username = "work";
          home.homeDirectory = "/Users/work";
          home.stateVersion = "25.11"; # Choose once for the new home; do not bump casually.
          myOptions = {
            neovim.enable = true;
            ideavim.enable = true;
            git.enable = true;
            fish.enable = true;
            zellij.enable = true;
          };
          programs.git.settings.user = {
            name = "Work Name";
            email = "work@example.com";
          };
        }
      ];
    };
  };
}
```

Commit the work flake's lockfile and pin a revision containing this refactor
after it is published. In a future Mac configuration within this repository,
import the same manifest directly and provide that host's native identity.

Existing PC-style editor shortcuts are shared unchanged. This does not claim to
remap every macOS application, reserve OS shortcuts, or translate physical
Command/Option/Control keys. Validate the real keyboard, terminal Option/Alt
handling, clipboard and IDE plugin on the Mac before adding host-only remapping.
No macOS key convention has been substituted.

### Deliberate API break

The former automatic `nixosModules.*`, broad `homeModules.*`, `vars`,
`homeModules.core/default` and global-vars bridge are no longer supported.
Consumers must migrate to the six named exports or their own native
configuration. This is a smaller intentional public contract, not a backwards-
compatible alias layer. The flake retains `overlays.default`, host outputs,
development shells, formatter and checks.

## Preservation and deferred risks

Whiteforest's root remains tmpfs (8G), with the existing /state UUID and /nix,
/persist bind layout. The generic engine retains system state and machine-id
handling; `users/max/persistence.nix` owns personal state. Ravenholm does not
acquire Whiteforest's persistence policy.

qBittorrent preserves both `.config/qBittorrent` and `.local/share/qBittorrent`:
these mixed-state directories contain categories/RSS configuration and resume
data, including SQLite storage and its sidecars, not only `BT_backup`. Directory
mounts allow applications to replace JSON/database files atomically. Home Manager
still regenerates its two `.conf` files and search-plugin links; GUI changes to
the generated `.conf` files are intentionally not retained across activation.
See [qBittorrent resume storage](https://github.com/qbittorrent/qBittorrent/blob/master/src/base/bittorrent/sessionimpl.cpp)
and [RSS state ownership](https://github.com/qbittorrent/qBittorrent/blob/master/src/base/rss/rss_session.cpp).

Mixed generated/mutable directories (for example JetBrains, Codex/Amp and
Vesktop) remain persisted where they contain authentication or user state.
A generated child is not grounds to delete its mutable parent.
[Preservation options](https://nix-community.github.io/preservation/configuration-options.html).

The following are deliberately not silently changed:

- Existing Miniflux credentials and network policy: the weak configured
  credentials warrant a separate authorized security change.
- Absolute local RSS proxy input: required for the existing personal deployment;
  source-only portable imports avoid it.
- Pinned search-plugin sources and existing application-specific activation
  scripts: retained, not upgraded as part of architecture work.
- Ravenholm's existing DP-3 Noctalia override and gamescope dimensions: unusual
  host values are preserved, not guessed from another machine.
- Full macOS application/global keyboard policy: requires a real work machine.
- Hardware, live service behavior and reboot persistence: evaluation is not a
  substitute for deployment testing.

## Verification record

`tests/snapshot.nix` compares concrete host configurations against a checkout
using the same locked inputs. Structural comparison found identical system
package derivations and identical home package selections except the expected
Neovim configuration derivation. Filesystems, firewall, stateVersions, Git,
Zellij, session settings and persistence inventory were compared before the
listed functional fixes. User group sets stayed the same (duplicate membership
removed). Moved home-file source paths and the narrower wallpaper source changed
store paths without changing the source payloads.

Package-list ordering changed some generated environment outputs and related
DBus/Polkit restart-trigger hashes. This is not presented as byte-for-byte
system closure equivalence: generated payloads and host closures still need full
build comparison. The final intentional differences include hook scripts,
Miniflux sync/OPML units, the binding fixes and qBittorrent state persistence.

| Check | Result / limit |
| --- | --- |
| Path-based `nix flake check --no-build --no-write-lock-file --offline` | Follow-up passed both hosts and all eight declared checks, including preservation |
| Every portable module alone, combined enabled/disabled, Linux and aarch64-darwin | Activation derivations evaluated; only enabled Neovim receives nixCats; disabled imports require no extra inputs; no personal identity or desktop leakage |
| Headless base + personal user | Evaluated without Hyprland/greetd; asserts OpenLDAP workaround applies only to the affected version |
| Git-hook disposable repository tests | Passed full staging with newline filename, partial-staging preflight, formatter failure, project marker and missing formatter |
| Miniflux fake endpoint + real jq + generated XML | Passed escaping, exact credentials, import/category update and missing-password failure |
| Password migration fake-shadow tests | Passed defaults, explicit users, permissions, no-clobber, locked/missing entries and traversal/symlink rejection |
| URL privacy tests | All nine passed |
| Neovim startup/keymap smoke | Passed using installed nixCats Neovim with temporary XDG/log paths and the new Lua files |
| Formatting | Installed Alejandra passes; follow-up staged-diff check found four Lua EOF blank-line warnings |
| Host dry-run builds | Blocked by denied Nix daemon socket access in this session |
| Actual flake check builds | All seven passed, including the rebuilt editor smoke check; final compatibility assertions rerun after the optional-input fix |
| Added qBittorrent preservation check | Native assertions evaluate true; covers both parent directories and retained generated-file policy |
| Deployment / Darwin build / physical keyboard | Not performed |
| Git stage/commit | Refactor is now staged; follow-up preservation/docs changes are unstaged; no refactor commit yet |

The checks are wired in `parts/checks.nix`. An actual
[`nix flake check`](https://nix.dev/manual/nix/2.34/command-ref/new-cli/nix3-flake-check.html)
builds/runs checks; `--no-build` does not.

### Follow-up source review

The second pass inventoried 132 non-ignored files before adding the preservation
test, parsed all 104 existing Nix files, and checked the staged diff rather than
only the unstaged diff. It found the following additional issues, **not fixed**
by the requested qBittorrent preservation change:

- **Git hook can stage an unrelated file:** a staged `literal[1].py` plus an
  untracked `literal1.py` causes the latter to be staged too. `--` ends option
  parsing but does not disable Git pathspec matching. Use literal pathspecs for
  both the per-file diff and add calls in
  [pre-commit.nix](../modules/home/core/git-hooks/pre-commit.nix).
  Reproduced in a disposable repository; see [Git pathspec semantics](https://git-scm.com/docs/gitglossary#Documentation/gitglossary.txt-aiddefpathspecapathspec).
- **Git hook formats through symlinks:** `[[ -f "$file" ]]` follows a symlink.
  A staged `.py` symlink can therefore change an unstaged target outside the
  repository. Reproduced with both a controlled formatter and installed Black.
  Skip symlinks before formatting; do not infer staged content from their targets.
- **Native debugger transport mismatch:**
  [debug.lua](../modules/home/core/neovim/lua/config/debug.lua) uses a CodeLLDB-style
  `--port` argument with `lldb-dap`. Installed LLDB 21.1.8 documents stdio or
  `--connection listen://...`, not `--port`; use its stdio executable adapter or
  correct TCP connection argument. Startup smoke tests do not start a debug
  session and therefore did not catch this. See [LLDB DAP documentation](https://lldb.llvm.org/use/lldbdap.html).

All three behaviors are also present in the checkpoint; they are not caused by
the file moves. Four new Lua files have an extra EOF blank line, so
`git diff --cached --check` currently fails despite Nix formatting passing.
The four ignored-but-tracked generated artifacts still require index cleanup.

For qBittorrent, this inspection found only generated configuration/plugin links
in the current profile, no running application and no existing resume data to
migrate. No live files were copied; recheck if the application is used before
activation. GUI changes to Nix-managed `.conf` files remain declarative overrides.

## Rollout and rollback

1. Review the uncommitted changes, including all new files. Stage them before
   using Git-backed `.` flake commands, or use `path:$PWD` during review.
2. Run the README's evaluation, executable checks and both host build commands in
   an environment with Nix daemon/cache access. Build without switching first.
3. **Before first Whiteforest activation, stop qBittorrent and preserve its
   existing mutable state.** Inspect `/home/max/.config/qBittorrent` and
   `/home/max/.local/share/qBittorrent`, with matching destinations under
   `/persist/home/max/`. If a source contains mutable files and its destination
   is absent, create only the destination parent and copy the directory with
   ownership/modes preserved. Do not dereference Nix-managed symlinks; Home
   Manager regenerates those config/plugin links. If the destination exists,
   back up and compare both before merging; do not overwrite it blindly.
   Verify contents and ownership before starting the application or rebooting.
   The new bind mounts must not hide the only copy of existing state.
   [qBittorrent state locations](https://github.com/qbittorrent/qBittorrent/wiki/Frequently-Asked-Questions).
4. Test/activate only when ready; confirm login, displays, audio, editor, Git
   hooks, torrent state and feed sync. Reboot testing is required for tmpfs-root
   state guarantees. No such activation has been performed by this refactor.
5. Keep the prior boot generation and checkpoint available. For configuration
   rollback, use the prior generation or build the checkpoint in a separate
   checkout; do not reset a dirty worktree or delete new persistent state.
   Reverting source does not undo live state migrations.

Once Git metadata is writable, remove only generated files from the index
(the following keeps local copies), review/stage source changes, and commit:

```sh
git rm --cached -- result nvim.log \
  modules/home/gui/url-privacy/__pycache__/test_url_privacy.cpython-313.pyc \
  modules/home/gui/url-privacy/__pycache__/url_privacy.cpython-313.pyc
git add -A
git diff --cached --check
git diff --cached --stat
```

## Checkpoint file-by-file ledger

“Retained” means the concern was reviewed and did not require architectural
rewriting; it is not a claim that every upstream application was runtime-tested.
Binary/log/build artifacts were classified, not treated as source code.
Paths below refer to the checkpoint so deletions and moves remain traceable.

| Checkpoint path | Disposition and reasoning |
| --- | --- |
| `.gitignore` | Updated: ignore build results, editor logs and Python bytecode; already tracked artifacts still need index cleanup. |
| `AGENTS.md` | Rewritten: current ownership, six-export contract and truthful verification rules replace stale discovery/vars guidance. |
| `assets/wallpaper.png` | Retained binary asset: same wallpaper; Noctalia references only its containing asset directory. |
| `docs/GIT_HOOKS.md` | Rewritten: actual installation, partial-staging safety, failure behavior and project-marker skip semantics. |
| `flake.lock` | Retained byte-for-byte: architecture work does not update dependency pins. |
| `flake.nix` | Removed automatic NixOS module export; retained locked inputs and explicit Home Manager manifest. |
| `hosts/default.nix` | Simplified native host constructor; only inputs passed, no import-all or whole legacy package-set argument. |
| `hosts/ravenholm/configuration.nix` | Explicit workstation/gaming/user imports; native hostname/stateVersion and host-owned gamescope dimensions. |
| `hosts/ravenholm/hardware-configuration.nix` | Retained: generated machine-specific hardware and filesystem facts. |
| `hosts/whiteforest/configuration.nix` | Explicit profiles/user imports; host services split into feeds, storage and home; retained host-specific hardware/kernel selections. |
| `hosts/whiteforest/hardware-configuration.nix` | Retained: generated hardware facts; tmpfs overrides owned by whiteforest/storage.nix. |
| `hosts/whiteforest/rss-archive-proxy.yaml` | Retained: host-specific proxy settings; no service/network policy changes. |
| `lib/default.nix` | Deleted empty helper entry point; real Minecraft helper has a direct import. |
| `modules/default.nix` | Deleted import-all root; host/profile imports expose composition directly. |
| `modules/home/core/agent-rules/default.nix` | Extracted instruction text to adjacent instructions.md; retained activation/config behavior. |
| `modules/home/core/amp/default.nix` | Extracted TypeScript plugin to impeccable.ts; retained mutable settings and activation. |
| `modules/home/core/btop/default.nix` | Retained focused Home Manager configuration; selected by personal base, not exported. |
| `modules/home/core/claude-code/default.nix` | Retained opt-in integration and mutable credentials/config strategy. |
| `modules/home/core/codex/default.nix` | Package recipe moved to packages/codex; existing mutable-config activation logic retained. |
| `modules/home/core/default.nix` | Replaced implicit aggregate with profiles/home/base.nix and development.nix. |
| `modules/home/core/devenv/default.nix` | Deleted package-only wrapper; devenv selected by development profile. |
| `modules/home/core/fish/default.nix` | Removed hook ownership; portable shell module keeps existing shell behavior. |
| `modules/home/core/fish/hooks.nix` | Moved to git-hooks/fish.nix; helpers enabled only with hooks and Fish. |
| `modules/home/core/fish/plugins.nix` | Retained pinned Fish plugin definitions. |
| `modules/home/core/git-hooks/default.nix` | Narrowed to hook/template composition; generator and formatter options adjacent; false/default no-op knobs removed. |
| `modules/home/core/git-hooks/files/editorconfig` | Retained formatter defaults; documentation no longer claims universal formatter support. |
| `modules/home/core/git/default.nix` | Removed personal identity and implicit hook enablement; native Git settings retained. |
| `modules/home/core/golang/default.nix` | Deleted package-only wrapper; Go/gopls/go-tools selected by development profile. |
| `modules/home/core/impeccable/default.nix` | Retained pinned skill installation integration; no UI redesign or skill input update. |
| `modules/home/core/intellij/codestyle.xml` | Retained IDE code-style payload unchanged. |
| `modules/home/core/intellij/default.nix` | Separated package construction, shared Minecraft libraries and independent IdeaVim settings. |
| `modules/home/core/intellij/ideavimrc` | Moved to core/ideavim/ideavimrc; removed shadowed Ctrl-K ParameterInfo mapping, retained effective window navigation. |
| `modules/home/core/java/default.nix` | Single owner of Temurin 17/21 links; duplicate ownership removed from Prism. |
| `modules/home/core/jj/default.nix` | Stable package selection centralized; personal Git identity supplied by user composition. |
| `modules/home/core/neovim/default.nix` | Portable export: explicit opt-in debug/Godot, optional nightly/ZLS/Styling; personal profile preserves enabled categories. |
| `modules/home/core/neovim/init.lua` | Reduced to ordered requires; existing statements split into five config Lua files, effective mappings preserved. |
| `modules/home/core/neovim/lua/nixCatsUtils/init.lua` | Retained nixCats utility boundary and non-Nix fallback behavior. |
| `modules/home/core/odin/default.nix` | Retained focused language-tooling module. |
| `modules/home/core/omp/default.nix` | Retained input-backed personal agent module. |
| `modules/home/core/opencode/default.nix` | Retained optional module, not imported by personal profiles; no speculative removal. |
| `modules/home/core/packwiz/default.nix` | Deleted package-only wrapper; packwiz selected by development profile. |
| `modules/home/core/shared/default.nix` | Deleted mixed global policy; user identity and desktop integration have explicit owners. |
| `modules/home/core/zellij/default.nix` | Retained portable opt-in multiplexer configuration and bindings. |
| `modules/home/core/zig/default.nix` | Retained focused input-backed language tooling module. |
| `modules/home/default.nix` | Deleted implicit core/GUI aggregate; profiles explicitly select each concern. |
| `modules/home/exports.nix` | Replaced directory scanning with six deliberate portable exports. |
| `modules/home/gui/aseprite/default.nix` | Deleted package-only wrapper; same package selected in profiles/home/desktop.nix. |
| `modules/home/gui/autostart/default.nix` | Retained focused, explicitly selected desktop feature; application settings/state behavior unchanged. |
| `modules/home/gui/blockbench/default.nix` | Deleted package-only wrapper; same package selected in profiles/home/desktop.nix. |
| `modules/home/gui/default.nix` | Moved composition into profiles/home/desktop.nix; simple package selections grouped there. |
| `modules/home/gui/discord/default.nix` | Vesktop recipe extracted while preserving its native override API; detect Stylix directly without vars. |
| `modules/home/gui/ghostty/default.nix` | Retained focused, explicitly selected desktop feature; application settings/state behavior unchanged. |
| `modules/home/gui/gimp/default.nix` | Deleted package-only wrapper; same package selected in profiles/home/desktop.nix. |
| `modules/home/gui/helium/default.nix` | Package recipe extracted; browser settings remain in Home Manager module. |
| `modules/home/gui/hyprland/default.nix` | Host workspace/display facts moved out; duplicate Alt-H action and unconditional Solaar startup removed. |
| `modules/home/gui/komikku/default.nix` | Deleted package-only wrapper; same package selected in profiles/home/desktop.nix. |
| `modules/home/gui/krita/default.nix` | Package recipe extracted; focused application policy retained. |
| `modules/home/gui/libreoffice/default.nix` | Stable package selection centralized; existing GUI integration retained. |
| `modules/home/gui/lockscreen/default.nix` | Retained focused, explicitly selected desktop feature; application settings/state behavior unchanged. |
| `modules/home/gui/nautilus/default.nix` | Removed hidden withGui enable default; desktop profile explicitly selects it. |
| `modules/home/gui/noctalia/default.nix` | Removed self/global-vars dependence; asset-only wallpaper path; monitor overrides owned by hosts. |
| `modules/home/gui/obs/default.nix` | Deleted one-option wrapper; native programs.obs-studio enabled in desktop profile. |
| `modules/home/gui/obsidian/default.nix` | Retained focused, explicitly selected desktop feature; application settings/state behavior unchanged. |
| `modules/home/gui/prism-launcher/default.nix` | Removed duplicate Temurin17/21 link ownership; retained remaining JDK links including optional legacy GraalVM. |
| `modules/home/gui/protonmail/default.nix` | Retained focused, explicitly selected desktop feature; application settings/state behavior unchanged. |
| `modules/home/gui/qbittorrent/default.nix` | Native homeDirectory replaces username bridge; force-overwrite comment corrected; search plugins/settings retained. |
| `modules/home/gui/ryujinx/default.nix` | Deleted package-only wrapper; same package selected in profiles/home/desktop.nix. |
| `modules/home/gui/screenshot/default.nix` | Retained focused, explicitly selected desktop feature; application settings/state behavior unchanged. |
| `modules/home/gui/signal/default.nix` | Retained focused, explicitly selected desktop feature; application settings/state behavior unchanged. |
| `modules/home/gui/spicetify/default.nix` | Retained optional configuration, not imported by current desktop profile; no speculative application removal. |
| `modules/home/gui/tauon/default.nix` | Deleted package-only wrapper; same package selected in profiles/home/desktop.nix. |
| `modules/home/gui/tidal/default.nix` | Retained focused, explicitly selected desktop feature; application settings/state behavior unchanged. |
| `modules/home/gui/url-privacy/__pycache__/test_url_privacy.cpython-313.pyc` | Generated Python bytecode, not auditable configuration source; original .py source tested. Pending untrack, retained locally. |
| `modules/home/gui/url-privacy/__pycache__/url_privacy.cpython-313.pyc` | Generated Python bytecode, not auditable configuration source; original .py source tested. Pending untrack, retained locally. |
| `modules/home/gui/url-privacy/default.nix` | Extracted package construction; existing MIME/browser integration retained. |
| `modules/home/gui/url-privacy/test_url_privacy.py` | Retained nine runnable regression cases; wired into flake checks. |
| `modules/home/gui/url-privacy/url_privacy.py` | Retained implementation; no URL policy changes. |
| `modules/home/gui/vlc/default.nix` | Deleted package-only wrapper; same package selected in profiles/home/desktop.nix. |
| `modules/home/gui/xournalpp/default.nix` | Deleted package-only wrapper; same package selected in profiles/home/desktop.nix. |
| `modules/nixos/amdgpu/default.nix` | Retained GPU policy; user render/video group ownership moved to users/max. |
| `modules/nixos/android/default.nix` | Extracted FHS recipe and user kvm-group ownership; optional feature remains disabled. |
| `modules/nixos/audio/default.nix` | Opt-in system feature; workstation profile owns enablement. |
| `modules/nixos/bluetooth/default.nix` | Opt-in system feature; workstation profile owns enablement. |
| `modules/nixos/default.nix` | Deleted automatic system aggregate; explicit profile and host imports replace it. |
| `modules/nixos/desktop/default.nix` | Deleted category aggregate; workstation imports concrete features. |
| `modules/nixos/desktop/hyprland.nix` | System compositor/service concern only; monitors and HM enablement moved to home composition. |
| `modules/nixos/desktop/lockscreen.nix` | Deleted cross-context wrapper; desktop Home Manager profile owns lockscreen feature. |
| `modules/nixos/exports.nix` | Deleted fragile discovery/public catch-all API; reusable surface is explicit Home Manager modules. |
| `modules/nixos/fonts/default.nix` | Opt-in system font policy; workstation enables it. |
| `modules/nixos/games/deadlock-mod-manager.nix` | Package recipe extracted; host still selects the same application. |
| `modules/nixos/games/default.nix` | Deleted category aggregate; gaming profile and host select features explicitly. |
| `modules/nixos/games/prism-launcher.nix` | Shared Minecraft library helper; user groups moved out; retained JDK/runtime differences. |
| `modules/nixos/games/steam.nix` | User gamemode group moved out; fixed display wrapper moved to parameterized host-owned package. |
| `modules/nixos/games/teamspeak.nix` | Retained focused opt-in system feature; host/profile remains the selection owner. |
| `modules/nixos/login/default.nix` | Opt-in greetd configuration; actual login user supplied by user composition. |
| `modules/nixos/logitech/default.nix` | System hardware concern only; whiteforest/home.nix owns the sole Solaar autostart. |
| `modules/nixos/memory/default.nix` | Retained focused opt-in system feature; host/profile remains the selection owner. |
| `modules/nixos/miniflux/default.nix` | Service composition only; escaped OPML and credential-aware sync script extracted with executable tests. |
| `modules/nixos/ml/default.nix` | Retained focused opt-in system feature; host/profile remains the selection owner. |
| `modules/nixos/multimedia/default.nix` | Retained focused opt-in system feature; host/profile remains the selection owner. |
| `modules/nixos/preservation/default.nix` | Native persistence engine/system state only; storage topology, user inventory and password policy separated. |
| `modules/nixos/protonvpn/default.nix` | Retained focused opt-in system feature; host/profile remains the selection owner. |
| `modules/nixos/shared/default.nix` | Moved native system baseline into profiles/nixos/base.nix; desktop-only settings moved to workstation. |
| `modules/nixos/shared/home-manager.nix` | Consolidated HM integration into users/max/nixos.nix; removed redundant bridge and special arguments. |
| `modules/nixos/shared/users.nix` | Moved personal account identity to users/max/nixos.nix. |
| `modules/nixos/shell/default.nix` | Deleted aggregate of cross-context wrappers. |
| `modules/nixos/shell/fish.nix` | Deleted wrapper; user owns login shell/system enablement, home profile owns shell configuration. |
| `modules/nixos/shell/neovim.nix` | Deleted wrapper; personal Home Manager profile owns editor selection. |
| `modules/nixos/tablet/default.nix` | Retained focused opt-in system feature; host/profile remains the selection owner. |
| `modules/nixos/theme/default.nix` | System Stylix policy only, opt-in; removed HM writes, retained effective palette/polarity. |
| `modules/nixos/vars/default.nix` | Deleted vars forwarding module; native user/host options have direct owners. |
| `modules/shared/formatters.nix` | Moved to git-hooks/formatters.nix; removed unused configuration surface. |
| `modules/shared/theme.nix` | Retained consumed values; removed dead CSS helpers and unused spacing/font knobs. |
| `modules/shared/vars.nix` | Deleted global identity/GUI/palette bridge; native options and explicit composition replace it. |
| `nvim.log` | Generated diagnostic log, not configuration; retained locally, pending untrack (Git metadata read-only). |
| `overlays/default.nix` | OpenLDAP workaround restricted to 2.6.13 and linked to upstream issue; other versions unchanged. |
| `parts/default.nix` | Retained flake outputs/dev shells; Minecraft helper removes duplicated library selection; checks imported separately. |
| `result` | Generated build-result symlink, not source; retained locally, pending untrack (Git metadata read-only). |
| `scripts/migrate-shadow-to-passwords.sh` | Fixed default users, no-clobber/atomic writes and validation; temporary fake-shadow tests, never run against live state. |

## New-file map

| New paths | Purpose |
| --- | --- |
| `README.md`, this audit | Entry point, comparison, compatibility and rollout record |
| `profiles/nixos/*.nix`, `profiles/home/*.nix` | Explicit capability selection, replacing implicit aggregate roots |
| `users/max/*.nix` | Account/HM identity, personal state and password policy |
| `hosts/*/home.nix`, `hosts/whiteforest/{storage,feeds}.nix` | Machine-specific facts moved to their owner |
| `packages/default.nix`, `packages/*/default.nix` | Existing package recipes, lazy selections and host-parameterized gamescope |
| `lib/minecraft-libraries.nix` | One shared ordered runtime-library list |
| `modules/home/core/ideavim/*` | Independently selectable shared IdeaVim configuration |
| `modules/home/core/neovim/lua/config/*.lua` | Existing editor startup split by concern |
| `modules/home/core/git-hooks/{fish,formatters,pre-commit}.nix` | Hook ownership and testable generator |
| `modules/home/core/agent-rules/instructions.md`, `modules/home/core/amp/impeccable.ts` | Existing non-Nix payloads separated from module wiring |
| `modules/nixos/miniflux/{opml.nix,sync-feeds.sh}` | Testable XML generation and API synchronization |
| `parts/checks.nix`, `tests/*` | Executable regression checks and read-only configuration snapshots |
