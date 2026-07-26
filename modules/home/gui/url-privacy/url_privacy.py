#!/usr/bin/env python3

import argparse
import os
import re
import sys
from urllib.parse import parse_qsl, urlencode, urlsplit, urlunsplit


TRACKING_KEYS = {
    "_hsenc",
    "_hsmi",
    "campaign",
    "campaign_id",
    "dclid",
    "fb_action_ids",
    "fb_action_types",
    "fb_ref",
    "fb_source",
    "fbclid",
    "gclid",
    "igshid",
    "mc_cid",
    "mc_eid",
    "mkt_tok",
    "ref_src",
    "ref_source",
    "ref_url",
    "share_id",
    "si",
    "spm",
    "twclid",
    "vero_conv",
    "vero_id",
    "yclid",
}

TRACKING_PREFIXES = (
    "utm_",
    "ga_",
    "pk_",
    "sc_",
)

FIXED_FRONTENDS = {
    "nitter.privacydev.net": "https://nitter.net",
    "twitter.com": "https://nitter.net",
    "x.com": "https://nitter.net",
}


def canonical_host(hostname: str | None) -> str:
    if not hostname:
        return ""
    host = hostname.lower().rstrip(".")
    for prefix in ("www.", "mobile.", "m.", "old.", "new.", "np.", "amp."):
        if host.startswith(prefix):
            return host[len(prefix) :]
    return host


def is_tracking_key(key: str) -> bool:
    lowered = key.lower()
    return lowered in TRACKING_KEYS or lowered.startswith(TRACKING_PREFIXES)


def sanitize_url(value: str) -> str:
    parsed = urlsplit(value)
    if parsed.scheme not in {"http", "https"} or not parsed.netloc:
        raise ValueError("expected one absolute HTTP(S) URL")

    query = [(key, item) for key, item in parse_qsl(parsed.query, keep_blank_values=True) if not is_tracking_key(key)]
    return urlunsplit((parsed.scheme, parsed.netloc, parsed.path, urlencode(query, doseq=True), parsed.fragment))


def redirect_url(value: str) -> str:
    parsed = urlsplit(value)
    host = canonical_host(parsed.hostname)

    frontend = FIXED_FRONTENDS.get(host)
    if frontend:
        target = urlsplit(frontend)
        return urlunsplit((target.scheme, target.netloc, parsed.path, parsed.query, parsed.fragment))

    return value


def transform(value: str, redirect: bool) -> str:
    cleaned = sanitize_url(value.strip())
    return redirect_url(cleaned) if redirect else cleaned


def command_transform(args: argparse.Namespace) -> int:
    try:
        print(transform(args.url, args.redirect))
    except ValueError as error:
        print(error, file=sys.stderr)
        return 2
    return 0


def command_open(args: argparse.Namespace) -> int:
    try:
        target = transform(args.url, True)
    except ValueError as error:
        print(error, file=sys.stderr)
        return 2
    os.execv(args.browser, [args.browser, target])
    return 0


def command_clipboard(_: argparse.Namespace) -> int:
    value = sys.stdin.read()
    stripped = value.strip()
    if not re.fullmatch(r"https?://\S+", stripped):
        return 0
    try:
        cleaned = transform(stripped, False)
    except ValueError:
        return 0
    if cleaned != stripped:
        print(cleaned, end="")
    return 0


def parser() -> argparse.ArgumentParser:
    root = argparse.ArgumentParser()
    commands = root.add_subparsers(required=True)

    transform_parser = commands.add_parser("transform")
    transform_parser.add_argument("--redirect", action="store_true")
    transform_parser.add_argument("url")
    transform_parser.set_defaults(func=command_transform)

    open_parser = commands.add_parser("open")
    open_parser.add_argument("--browser", required=True)
    open_parser.add_argument("url")
    open_parser.set_defaults(func=command_open)

    clipboard_parser = commands.add_parser("clipboard")
    clipboard_parser.set_defaults(func=command_clipboard)
    return root


if __name__ == "__main__":
    arguments = parser().parse_args()
    raise SystemExit(arguments.func(arguments))
