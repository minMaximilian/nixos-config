#!/usr/bin/env python3
"""Exercise XML escaping and sync credentials without a running Miniflux."""
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET


opml = sys.stdin.read() if sys.argv[1] == "-" else Path(sys.argv[1]).read_text()
category = 'News & "More" <test>'
url = "https://example.test/?a=1&b=2"
outline = ET.fromstring(opml).find("body/outline")
assert outline.attrib == {"text": category, "title": category}
assert outline[0].attrib == {
    "text": 'Feed & "title"',
    "title": 'Feed & "title"',
    "type": "rss",
    "xmlUrl": url,
}

with tempfile.TemporaryDirectory() as directory:
    fixture = Path(directory)
    (fixture / "opml").write_text(opml)
    (fixture / "categories").write_text(json.dumps({url: category}))
    curl = fixture / "curl"
    curl.write_text(f"#!{sys.executable}\n" + r'''
import json, os, sys
from pathlib import Path
args = sys.argv[1:]
endpoint = args[-1]
if endpoint.endswith("/healthcheck"):
    sys.exit(0)
assert args[args.index("-u") + 1] == os.environ["EXPECTED_AUTH"]
with open(os.environ["TEST_REQUESTS"], "a") as requests:
    requests.write(json.dumps(args) + "\n")
if endpoint.endswith("/import"):
    assert Path(args[args.index("--data-binary") + 1][1:]).read_text().startswith("<?xml")
    print("{}")
elif endpoint.endswith("/categories"):
    print(json.dumps([{"id": 2, "title": os.environ["TEST_CATEGORY"]}]))
elif endpoint.endswith("/feeds"):
    print(json.dumps([{"id": 1, "feed_url": os.environ["TEST_URL"], "category": {"title": "Old"}}]))
elif endpoint.endswith("/feeds/1"):
    assert args[args.index("-X") + 1] == "PUT"
    assert json.loads(args[args.index("-d") + 1]) == {"category_id": 2}
else:
    raise AssertionError(endpoint)
''')
    curl.chmod(0o700)
    environment = {
        **os.environ,
        "PATH": directory + os.pathsep + os.environ["PATH"],
        "ADMIN_USERNAME": "work=user",
        "ADMIN_PASSWORD": "has=equals 'quotes' \\ spaces",
        "EXPECTED_AUTH": "work=user:has=equals 'quotes' \\ spaces",
        "MINIFLUX_URL": "http://fixture.invalid",
        "OPML_FILE": str(fixture / "opml"),
        "FEED_CATEGORY_MAP": str(fixture / "categories"),
        "TEST_REQUESTS": str(fixture / "requests"),
        "TEST_CATEGORY": category,
        "TEST_URL": url,
    }
    subprocess.run(["bash", sys.argv[2]], env=environment, check=True)
    requests = (fixture / "requests").read_text().splitlines()
    assert len(requests) == 4
    environment.pop("ADMIN_PASSWORD")
    missing = subprocess.run(["bash", sys.argv[2]], env=environment, capture_output=True)
    assert missing.returncode != 0
    assert b"ADMIN_PASSWORD is required" in missing.stderr
    assert (fixture / "requests").read_text().splitlines() == requests

print("Miniflux XML and credential checks passed.")
