"""Verify the runtime and bundled plugins in an Android release APK."""

import argparse
from pathlib import Path
from zipfile import ZipFile


def check_apk(path):
    app = Path(__file__).resolve().parents[1] / "Luotopia-app"
    with ZipFile(path) as apk:
        engines = [
            name for name in apk.namelist()
            if name.startswith("lib/") and name.endswith("/libflutter.so")
        ]
        if not engines:
            raise ValueError("APK has no Flutter engine")
        for engine in engines:
            apk.getinfo(engine.removesuffix("libflutter.so") + "libflutter_qjs_next.so")
        for directory in ("assets/system_plugins", "assets/market"):
            packages = sorted((app / directory).glob("*.luoplugin"))
            if not packages:
                raise ValueError(f"No source plugins found in {directory}")
            for package in packages:
                asset = "assets/flutter_assets/" + package.relative_to(app).as_posix()
                if apk.read(asset) != package.read_bytes():
                    raise ValueError(f"Packaged plugin differs from source: {asset}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("apk", type=Path)
    check_apk(parser.parse_args().apk)
