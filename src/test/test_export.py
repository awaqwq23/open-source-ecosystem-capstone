import io
import unittest

from check_export import check_export


class ExportContractTests(unittest.TestCase):
    def test_sample_export(self):
        check_export(io.StringIO('date,location\n2026-09-07,"A,101"\n2026-09-21,B\n'), "date")

    def test_wrong_week_missing_and_duplicate_rows(self):
        for dates in (["2026-09-07", "2026-09-14"], ["2026-09-07"],
                      ["2026-09-07", "2026-09-07"], []):
            with self.subTest(dates=dates), self.assertRaises(ValueError):
                check_export(io.StringIO("\n".join(["date", *dates])), "date")
