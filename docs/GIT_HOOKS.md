# Global Git formatting hook

The personal base profile explicitly enables both Git and Git hooks. External
consumers can import and enable `homeModules.git-hooks` separately; importing
`homeModules.git` does not turn hooks on.

## Installation

Home Manager provides `~/.config/git/templates/hooks/pre-commit`,
`~/.editorconfig`, formatter packages and Git's `init.templateDir` setting.
Git copies templates when initializing repositories; updating the template does
not automatically replace hooks in existing repositories.
See [Git's hook documentation](https://git-scm.com/docs/githooks).

With Fish and this module enabled:

| Command | Abbreviation | Action |
| --- | --- | --- |
| `git-init-hooks` | `gih` | Copy template hooks into the current repository |
| `git-disable-hooks` | `gdh` | Rename pre-commit to pre-commit.disabled |
| `git-enable-hooks` | `geh` | Rename it back |

**Inspect and back up existing hooks first.** The copy command overwrites
same-named files, and the rename commands can replace an existing destination.
These helpers use the repository's Git directory; they do not manage a custom
`core.hooksPath`. Do not run them in a repository whose hook manager owns that
directory. There is no `git-format-repo` helper.

## Commit behavior

1. If Husky, Lefthook, pre-commit or treefmt markers are present, exit successfully
   without formatting. This does **not** invoke that project's tool; install its
   pipeline separately.
2. Inspect all staged additions, copies, modifications and renames before
   formatting. Reject a staged path with unstaged edits, leaving the index and
   working tree unchanged. Stage or stash the remaining edits before retrying.
3. Match staged filenames to formatter rules. Prefer an executable in
   `node_modules/.bin`, then PATH, using the first available invocation.
4. Format the whole file and re-stage it. A formatter failure aborts the commit;
   it does not silently try another formatter. A missing formatter or unmatched
   filename is skipped.

Paths are NUL-delimited to support spaces and newlines. The hook is not a
transaction across formatter invocations: if a later formatter fails, earlier
successful formatting/re-staging remains. Review the diff before retrying.

Project markers checked: `.husky/`, `.lefthook/`,
`lefthook.{yml,yaml}`, `.lefthook.{yml,yaml}`,
`.pre-commit-config.{yml,yaml}`, `treefmt.toml`, `treefmt.nix`.

## Configuration

```nix
myOptions.git-hooks.enable = true;
myOptions.formatters.verbose = true;
# Override a rule; arguments are separate strings, not shell commands.
myOptions.formatters.systemFormatters.".*\\\\.py$" = [
  [ "black" "--quiet" ]
];
```

The hook appends the filename as the final argument. Rules are Nix attribute
names (lexically ordered); keep patterns non-overlapping. Invocation lists must
contain a command. Defaults cover Nix, Go, Python, Rust, shell, YAML, TOML, Lua,
JS/TS, JSON, Markdown, CSS, HTML, Vue/Svelte and GraphQL. Formatter behavior comes
from each formatter's supported project configuration; `.editorconfig` support
is not universal.

Implementation: `modules/home/core/git-hooks/`. Regression test:
`tests/test_git_hook.py`, exercised by `checks.x86_64-linux.git-hooks`.
