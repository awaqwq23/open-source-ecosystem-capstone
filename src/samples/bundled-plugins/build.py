"""Rebuild trusted application assets only; external SDK still rejects reserved IDs."""
from pathlib import Path
import json
import zipfile

root = Path(__file__).resolve().parent
output = root.parents[1] / "Luotopia-app" / "assets" / "system_plugins"
output.mkdir(parents=True, exist_ok=True)
for source in sorted(p for p in root.iterdir() if p.is_dir()):
    manifest = json.loads((source / "manifest.json").read_text(encoding="utf-8"))
    assert manifest["id"].startswith("luotopia.")
    assert {p.name for p in source.iterdir()} == {"manifest.json", "main.js", "LICENSE.txt"}
    target = output / f"{source.name}-{manifest['version']}.luoplugin"
    with zipfile.ZipFile(target, "w") as archive:
        for name in ("manifest.json", "main.js", "LICENSE.txt"):
            entry = zipfile.ZipInfo(name, (2026, 1, 1, 0, 0, 0))
            entry.compress_type = zipfile.ZIP_DEFLATED
            archive.writestr(entry, (source / name).read_bytes())
    print(target.name)
