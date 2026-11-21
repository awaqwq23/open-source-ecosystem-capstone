import copy
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
import zipfile

SDK = Path(__file__).resolve().parents[1]
SAMPLE = SDK.parents[1] / 'samples/plugins/study-time'


class PackTests(unittest.TestCase):
    def run_pack(self, change=None, extra=None):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / 'plugin'
            source.mkdir()
            manifest = json.loads((SAMPLE / 'manifest.json').read_text(encoding='utf-8'))
            if change:
                change(manifest)
            (source / 'manifest.json').write_text(json.dumps(manifest), encoding='utf-8')
            (source / 'main.js').write_bytes((SAMPLE / 'main.js').read_bytes())
            (source / 'LICENSE.txt').write_text('MIT', encoding='utf-8')
            if extra:
                extra(source)
            output = root / 'sample.luoplugin'
            result = subprocess.run([sys.executable, str(SDK / 'pack.py'), str(source), str(output)], capture_output=True, text=True)
            files = None
            if output.exists():
                with zipfile.ZipFile(output) as archive:
                    files = {name: archive.read(name) for name in archive.namelist()}
            return result, files

    def test_package_content(self):
        result, files = self.run_pack()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(set(files), {'manifest.json', 'main.js', 'LICENSE.txt'})
        self.assertEqual(json.loads(files['manifest.json'])['id'], 'org.example.study-time')

    def test_invalid_manifest(self):
        changes = [lambda m: m.update(id='luotopia.fake'), lambda m: m.update(id='../evil'),
                   lambda m: m.update(apiVersion=2), lambda m: m.update(schemaVersion=True),
                   lambda m: m.update(version='01.0.0'), lambda m: m.update(entry='../main.js'),
                   lambda m: m.update(core=True), lambda m: m.update(permissions=['unknown']),
                   lambda m: m['contributions'][0].update(allowedViews=['preferences']),
                   lambda m: m['contributions'].append(copy.deepcopy(m['contributions'][0])),
                   lambda m: m['config'][0].update(default=2000),
                   lambda m: m['config'][0].update(key='not.a.config.key'),
                   lambda m: m.update(config=[{'key': 'choice', 'type': 'choice', 'label': 'Choice', 'default': 'v0', 'options': [{'value': 'v' + str(i), 'label': str(i)} for i in range(101)]}])]
        for change in changes:
            with self.subTest(change=change):
                result, files = self.run_pack(change)
                self.assertNotEqual(result.returncode, 0)
                self.assertIsNone(files)

    def test_bad_files_and_limits(self):
        for extra in [lambda p: (p / 'extra.js').write_text('x'),
                      lambda p: (p / 'nested').mkdir(),
                      lambda p: (p / 'main.js').write_bytes(b'x' * (2 * 1024 * 1024 + 1)),
                      lambda p: (p / 'LICENSE.txt').write_bytes(b'\xff')]:
            result, files = self.run_pack(extra=extra)
            self.assertNotEqual(result.returncode, 0, result.stdout)
            self.assertIsNone(files)

    def test_duplicate_json_key(self):
        def duplicate(source):
            path = source / 'manifest.json'
            path.write_text('{"apiVersion":1,' + path.read_text(encoding='utf-8')[1:], encoding='utf-8')
        result, files = self.run_pack(extra=duplicate)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('duplicate JSON key', result.stderr)
        self.assertIsNone(files)

    def test_host_metadata_counts_and_utf16_limits(self):
        changes = {
            'name': lambda m: m.update(name='x' * 129),
            'author': lambda m: m.update(author='x' * 129),
            'license metadata': lambda m: m.update(license='x' * 129),
            'description': lambda m: m.update(description='x' * 2001),
            'version length': lambda m: m.update(version='1' * 29 + '.0.0'),
            'views': lambda m: m.update(views=['main', 'preferences'] + ['v' + str(i) for i in range(31)]),
            'config count': lambda m: m.update(config=[{'key': 'k' + str(i), 'type': 'boolean', 'label': 'K', 'default': False} for i in range(33)]),
            'hosts count': lambda m: m.update(permissions=['network.https'], networkHosts=['h' + str(i) + '.example.com' for i in range(17)]),
            'host tld': lambda m: m.update(permissions=['network.https'], networkHosts=['example.c0m']),
            'icon': lambda m: m['contributions'][0].update(icon='unknown'),
            'color': lambda m: m['contributions'][1].update(color='unknown'),
            'title': lambda m: m['contributions'][0].update(title='x' * 65),
            'config label': lambda m: m['config'][0].update(label='x' * 129),
            'UTF16 metadata': lambda m: m.update(name='😀' * 65),
            'UTF16 default': lambda m: m.update(config=[{'key': 'caption', 'type': 'text', 'label': 'Caption', 'default': '😀😀😀', 'maxLength': 4}]),
            'choice value': lambda m: m.update(config=[{'key': 'unit', 'type': 'choice', 'label': 'Unit', 'default': 'x' * 129, 'options': [{'value': 'x' * 129, 'label': 'X'}]}]),
            'choice label': lambda m: m.update(config=[{'key': 'unit', 'type': 'choice', 'label': 'Unit', 'default': 'm', 'options': [{'value': 'm', 'label': '😀' * 65}]}]),
        }
        for name, change in changes.items():
            with self.subTest(name=name):
                result, files = self.run_pack(change)
                self.assertNotEqual(result.returncode, 0)
                self.assertIsNone(files)
        result, files = self.run_pack(extra=lambda p: (p / 'LICENSE.txt').write_bytes(b'x' * (1024 * 1024 + 1)))
        self.assertNotEqual(result.returncode, 0)
        self.assertIsNone(files)

    def test_host_boundaries_are_accepted(self):
        def boundary(m):
            m.update(name='😀' * 64, description='x' * 2000, author='x' * 128, license='x' * 128,
                     permissions=['network.https'], networkHosts=['h' + str(i) + '.example.com' for i in range(16)],
                     views=['main', 'preferences'] + ['v' + str(i) for i in range(30)],
                     config=[{'key': 'caption', 'type': 'text', 'label': 'x' * 128, 'default': '😀😀', 'maxLength': 4}] +
                            [{'key': 'k' + str(i), 'type': 'boolean', 'label': 'K', 'default': False} for i in range(31)])
            m['contributions'][0]['title'] = '😀' * 32
        result, files = self.run_pack(boundary, extra=lambda p: (p / 'LICENSE.txt').write_bytes(b'x' * (1024 * 1024)))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(len(files['LICENSE.txt']), 1024 * 1024)

    def test_payload_dart_whitespace_is_not_a_script_or_license(self):
        for name in ('main.js', 'LICENSE.txt'):
            with self.subTest(name=name):
                result, files = self.run_pack(extra=lambda p: (p / name).write_text('\ufeff\u2000', encoding='utf-8'))
                self.assertNotEqual(result.returncode, 0)
                self.assertIsNone(files)

    def test_existing_output_is_preserved(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for name in ('manifest.json', 'main.js', 'LICENSE.txt'):
                (root / name).write_bytes((SAMPLE / name).read_bytes())
            output = root.parent / (root.name + '.luoplugin')
            try:
                output.write_bytes(b'previous release')
                result = subprocess.run([sys.executable, str(SDK / 'pack.py'), str(root), str(output)], capture_output=True)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(output.read_bytes(), b'previous release')
            finally:
                output.unlink(missing_ok=True)


if __name__ == '__main__':
    unittest.main()
