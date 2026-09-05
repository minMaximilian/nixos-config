import importlib.util
from pathlib import Path
import unittest


MODULE_PATH = Path(__file__).with_name("url_privacy.py")
SPEC = importlib.util.spec_from_file_location("url_privacy", MODULE_PATH)
url_privacy = importlib.util.module_from_spec(SPEC)
assert SPEC.loader
SPEC.loader.exec_module(url_privacy)


class UrlPrivacyTests(unittest.TestCase):
    def test_removes_tracking_parameters_and_preserves_content(self):
        value = "https://example.com/page?id=42&utm_source=test&igsi=NTc4MTIwNjQ2YQ%3D%3D&si=secret#part"
        self.assertEqual(url_privacy.transform(value, False), "https://example.com/page?id=42#part")

    def test_redirects_x_after_cleaning(self):
        value = "https://x.com/example/status/1?utm_source=test"
        self.assertEqual(
            url_privacy.transform(value, True),
            "https://twitterviewer.net/example/status/1",
        )

    def test_normalizes_old_nitter_instance(self):
        value = "https://nitter.privacydev.net/riotgames/status/2057879738350444726?lang=en#m"
        self.assertEqual(
            url_privacy.transform(value, True),
            "https://twitterviewer.net/riotgames/status/2057879738350444726?lang=en#m",
        )

    def test_normalizes_nitter_net(self):
        value = "https://nitter.net/example/status/1"
        self.assertEqual(
            url_privacy.transform(value, True),
            "https://twitterviewer.net/example/status/1",
        )

    def test_leaves_other_frontends_to_browser_extension(self):
        value = "https://youtu.be/abc123?si=secret&t=20"
        self.assertEqual(
            url_privacy.transform(value, True),
            "https://youtu.be/abc123?t=20",
        )

    def test_cleans_fandom_before_browser_extension(self):
        value = "https://example.fandom.com/wiki/Page?utm_medium=share"
        self.assertEqual(
            url_privacy.transform(value, True),
            "https://example.fandom.com/wiki/Page",
        )

    def test_removes_reddit_referral_source(self):
        value = "https://www.reddit.com/r/nixos/comments/example?ref_source=embed"
        self.assertEqual(
            url_privacy.transform(value, True),
            "https://www.reddit.com/r/nixos/comments/example",
        )

    def test_does_not_hardcode_other_public_instances(self):
        values = (
            "https://www.instagram.com/p/example/",
            "https://www.reddit.com/r/nixos/",
            "https://www.tiktok.com/@example/video/1",
            "https://medium.com/@example/post",
            "https://www.quora.com/example",
            "https://imgur.com/example",
            "https://www.imdb.com/title/tt0000001/",
            "https://www.twitch.tv/example",
            "https://bsky.app/profile/example.test",
            "https://www.pinterest.com/pin/1/",
            "https://www.youtube.com/watch?v=abc123",
            "https://example.fandom.com/wiki/Page",
            "https://www.google.com/search?q=nixos",
        )
        for value in values:
            with self.subTest(value=value):
                self.assertEqual(url_privacy.transform(value, True), value)

    def test_rejects_non_http_urls(self):
        with self.assertRaises(ValueError):
            url_privacy.transform("file:///tmp/example", False)


if __name__ == "__main__":
    unittest.main()
