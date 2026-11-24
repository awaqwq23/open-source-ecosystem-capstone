import sys
import unittest
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / ".github/scripts"))
import select_apk


class TagReleaseTests(unittest.TestCase):
    sha = "a" * 40

    def select(self, runs, assets, artifact_id=""):
        def pages(endpoint):
            if "/workflows/" in endpoint:
                return [{"workflow_runs": runs}]
            return [{"artifacts": assets}]

        with patch.dict("os.environ", GITHUB_REPOSITORY="team/app"), patch.object(select_apk, "pages", pages):
            return select_apk.select(self.sha, artifact_id)

    def run_info(self, **changes):
        return dict(dict(id=101, head_sha=self.sha, head_branch="main", event="push",
                         conclusion="success", run_attempt=1), **changes)

    def asset(self, **changes):
        return dict(dict(id=42, expired=False, name=f"signed-apk-{self.sha}-1"), **changes)

    def test_unique_artifact(self):
        self.assertEqual(self.select([self.run_info()], [self.asset()]), (101, 42))

    def test_explicit_selection_required_for_ambiguous_builds(self):
        assets = [self.asset(), self.asset(id=43)]
        with self.assertRaises(ValueError):
            self.select([self.run_info()], assets)
        self.assertEqual(self.select([self.run_info()], assets, "43"), (101, 43))
        with self.assertRaises(ValueError):
            self.select([self.run_info()], assets, "44")

    def test_reject_untrusted_or_unavailable_artifacts(self):
        for changes in [dict(event="pull_request"), dict(conclusion="failure"), dict(head_branch="devops"),
                        dict(head_sha="b" * 40), dict(run_attempt=2)]:
            with self.subTest(changes=changes), self.assertRaises(ValueError):
                self.select([self.run_info(**changes)], [self.asset()])
        with self.assertRaises(ValueError):
            self.select([self.run_info()], [self.asset(expired=True)])
