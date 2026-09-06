"""Exercise the generated hook in disposable repositories, never the real index."""
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile


def main(hook):
    env = {k: v for k, v in os.environ.items() if not k.startswith("GIT_")}
    env.update(GIT_CONFIG_GLOBAL=os.devnull, GIT_CONFIG_SYSTEM=os.devnull)
    with tempfile.TemporaryDirectory(prefix="git-hook-test-") as temporary:
        root = Path(temporary)
        empty_template = root / "empty-template"
        empty_template.mkdir()
        commands = root / "bin"
        commands.mkdir()
        formatter = commands / "black"
        formatter.write_text(
            f"#!{shutil.which('bash')}\n"
            "test ! -f .formatter-fails || exit 7\n"
            'for file; do :; done\nprintf "formatted\\n" > "$file"\n'
        )
        formatter.chmod(0o755)
        env["PATH"] = str(commands) + os.pathsep + env["PATH"]

        def repository(name):
            path = root / name
            path.mkdir()
            subprocess.run(
                ["git", "init", "-q", "--template=" + str(empty_template), str(path)],
                env=env, check=True,
            )
            return path

        def git(path, *args):
            return subprocess.check_output(["git", *args], cwd=path, env=env)

        def run(path):
            return subprocess.run(
                ["bash", hook], cwd=path, env=env, capture_output=True,
            )

        full = repository("full")
        unusual = "file with\na newline.py"
        (full / unusual).write_text("unformatted\n")
        git(full, "add", "--", unusual)
        assert run(full).returncode == 0
        assert git(full, "show", ":" + unusual) == b"formatted\n"

        partial = repository("partial")
        for name in ("a.py", "z.py"):
            (partial / name).write_text("staged\n")
        git(partial, "add", ".")
        (partial / "z.py").write_text("unstaged\n")
        index_before = git(partial, "write-tree")
        result = run(partial)
        assert result.returncode != 0 and b"partially staged" in result.stderr
        assert git(partial, "write-tree") == index_before
        assert (partial / "a.py").read_text() == "staged\n"
        assert (partial / "z.py").read_text() == "unstaged\n"

        failure = repository("failure")
        (failure / "a.py").write_text("unformatted\n")
        git(failure, "add", "a.py")
        (failure / ".formatter-fails").touch()
        assert run(failure).returncode != 0
        assert git(failure, "show", ":a.py") == b"unformatted\n"

        delegated = repository("delegated")
        (delegated / "a.py").write_text("staged\n")
        git(delegated, "add", "a.py")
        (delegated / "a.py").write_text("unstaged\n")
        (delegated / "treefmt.nix").touch()
        assert run(delegated).returncode == 0
        assert git(delegated, "show", ":a.py") == b"staged\n"

        missing = repository("missing")
        (missing / "a.missing").write_text("unchanged\n")
        git(missing, "add", "a.missing")
        assert run(missing).returncode == 0
        assert git(missing, "show", ":a.missing") == b"unchanged\n"
    print("Git hook: formatting, partial staging, failure, delegation, missing formatter passed")


if __name__ == "__main__":
    main(str(Path(sys.argv[1]).resolve()))
