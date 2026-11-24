"""SPI v1 author-side preflight and ZIP builder. Host validation is authoritative."""
import argparse
import io
import json
import math
from pathlib import Path
import re
import sys
import zipfile

MIB = 1024 * 1024
FILES = {'manifest.json': 64 * 1024, 'main.js': 2 * MIB, 'LICENSE.txt': MIB}
LOCAL_ID = r'[a-z][a-z0-9_-]{0,47}'
ICONS = {'timer', 'tune', 'home', 'list', 'forum', 'school', 'settings', 'book', 'calendar', 'star', 'code', 'cloud', 'chart', 'info'}
COLORS = {'sky', 'blue', 'green', 'amber', 'purple', 'pink', 'slate'}


def require(condition, message):
    if not condition:
        raise ValueError(message)


def unique_strings(value, pattern=None):
    require(isinstance(value, list) and all(isinstance(x, str) and x for x in value), 'expected string list')
    require(len(set(value)) == len(value), 'duplicate list entry')
    if pattern:
        require(all(re.fullmatch(pattern, x) for x in value), 'invalid identifier')
    return value


def finite(value):
    try:
        return type(value) in (int, float) and math.isfinite(value)
    except OverflowError:
        return False


def text(value, maximum, empty=False):
    # Dart and JavaScript String.length count UTF-16 code units, not code points.
    return isinstance(value, str) and (empty or value != '') and len(value.encode('utf-16-le', errors='surrogatepass')) // 2 <= maximum


def validate_manifest(m):
    require(isinstance(m, dict), 'manifest must be an object')
    fields = {'schemaVersion', 'id', 'name', 'version', 'apiVersion', 'entry', 'description', 'author', 'license', 'permissions', 'networkHosts', 'views', 'contributions', 'config'}
    require(set(m) == fields, 'missing or unknown manifest field')
    require(type(m['schemaVersion']) is int and m['schemaVersion'] == 1 and type(m['apiVersion']) is int and m['apiVersion'] == 1, 'unsupported schema/API')
    identity = m['id']
    require(isinstance(identity, str) and len(identity) <= 96 and re.fullmatch(r'[a-z][a-z0-9]*(?:[.-][a-z0-9]+)+', identity), 'invalid plugin ID')
    require(not identity.startswith('luotopia.'), 'reserved plugin ID')
    require(text(m['version'], 32) and re.fullmatch(r'(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)', m['version']), 'invalid release version')
    require(m['entry'] == 'main.js', 'entry must be main.js')
    for key in ('name', 'description', 'author', 'license'):
        require(text(m[key], 2000 if key == 'description' else 128), 'invalid metadata: ' + key)
    permissions = unique_strings(m['permissions'])
    require(set(permissions) <= {'storage.self', 'network.https', 'schoolTimetable.read'}, 'unknown permission')
    hosts = unique_strings(m['networkHosts'])
    require(len(hosts) <= 16, 'networkHosts count exceeds 16')
    require(not hosts or 'network.https' in permissions, 'networkHosts requires network.https')
    for host in hosts:
        require(len(host) <= 253 and re.fullmatch(r'(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,63}', host), 'invalid exact network host')
    views = unique_strings(m['views'], LOCAL_ID)
    require(1 <= len(views) <= 32, 'views count must be 1..32')
    contributions = m['contributions']
    require(isinstance(contributions, list) and 1 <= len(contributions) <= 32, 'contribution count must be 1..32')
    ids = set()
    for c in contributions:
        require(isinstance(c, dict), 'contribution must be object')
        required = {'id', 'slot', 'title', 'icon', 'viewId', 'allowedViews'}
        require(required <= set(c) and set(c) <= required | {'size', 'color', 'group'}, 'unknown/missing contribution field')
        require(isinstance(c['id'], str) and re.fullmatch(LOCAL_ID, c['id']) and c['id'] not in ids, 'invalid/duplicate contribution ID')
        ids.add(c['id'])
        require(c['slot'] in ('navigation', 'campusCard', 'settingsRow'), 'invalid contribution slot')
        require(text(c['title'], 64) and isinstance(c['icon'], str) and c['icon'] in ICONS and isinstance(c['viewId'], str), 'invalid contribution metadata/icon')
        allowed = unique_strings(c['allowedViews'], LOCAL_ID)
        require(c['viewId'] in allowed and set(allowed) <= set(views), 'invalid allowedViews')
        require(c.get('size') is None or c['slot'] == 'campusCard' and c['size'] in ('small', 'wide'), 'invalid card size')
        require('color' not in c or c['color'] is None or c['slot'] == 'campusCard' and isinstance(c['color'], str) and c['color'] in COLORS, 'invalid card color')
        require(c.get('group') is None or c['slot'] == 'settingsRow' and c['group'] == 'extensions', 'invalid settings group')
    require(isinstance(m['config'], list) and len(m['config']) <= 32, 'config count exceeds 32')
    keys = set()
    for field in m['config']:
        require(isinstance(field, dict), 'config field must be object')
        base = {'key', 'type', 'label', 'default'}
        require(base <= set(field), 'missing config field')
        key, kind, default = field['key'], field['type'], field['default']
        require(isinstance(key, str) and re.fullmatch(r'[a-zA-Z][a-zA-Z0-9_]{0,47}', key) and key not in keys, 'invalid/duplicate config key')
        keys.add(key)
        require(text(field['label'], 128), 'invalid config label')
        extras = {'text': {'maxLength'}, 'number': {'min', 'max'}, 'boolean': set(), 'choice': {'options'}}
        require(isinstance(kind, str) and kind in extras and set(field) == base | extras[kind], 'unknown config type/field')
        if kind == 'text':
            require(type(field['maxLength']) is int and 1 <= field['maxLength'] <= 4096 and text(default, field['maxLength'], empty=True), 'invalid text bounds/default')
        elif kind == 'number':
            require(all(finite(x) for x in (field['min'], field['max'], default)) and field['min'] <= default <= field['max'], 'invalid number bounds/default')
        elif kind == 'boolean':
            require(type(default) is bool, 'invalid boolean default')
        else:
            options = field['options']
            require(isinstance(options, list) and 1 <= len(options) <= 100, 'invalid choices')
            require(all(isinstance(o, dict) and set(o) == {'value', 'label'} and all(text(v, 128) for v in o.values()) for o in options), 'invalid choice option')
            values = unique_strings([o['value'] for o in options])
            require(isinstance(default, str) and default in values, 'invalid choice default')


def object_pairs(pairs):
    result = {}
    for key, value in pairs:
        require(key not in result, 'duplicate JSON key: ' + key)
        result[key] = value
    return result


def package(source, output):
    require(source.is_dir(), 'source must be a directory')
    # Developer/test files can coexist beside the three payload files, but payload
    # must be staged alone so accidental secrets cannot enter the archive.
    entries = list(source.iterdir())
    require({p.name for p in entries} == set(FILES), 'source must contain exactly manifest.json, main.js, LICENSE.txt')
    payload = {}
    for path in entries:
        require(not path.is_symlink() and not path.is_junction() and path.is_file(), 'non-regular payload file')
        require(path.stat().st_size <= FILES[path.name], 'file size limit: ' + path.name)
        with path.open('rb') as stream:
            payload[path.name] = stream.read(FILES[path.name] + 1)
        require(len(payload[path.name]) <= FILES[path.name], 'file size limit: ' + path.name)
        payload[path.name].decode('utf-8')
    require(sum(map(len, payload.values())) <= 10 * MIB, 'uncompressed limit exceeded')
    manifest = json.loads(payload['manifest.json'].decode('utf-8'), object_pairs_hook=object_pairs, parse_constant=lambda _: (_ for _ in ()).throw(ValueError('non-finite JSON number')))
    validate_manifest(manifest)
    dart_whitespace = '\u0009\u000a\u000b\u000c\u000d\u0020\u0085\u00a0\u1680\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200a\u2028\u2029\u202f\u205f\u3000\ufeff'
    require(all(payload[name].decode('utf-8').strip(dart_whitespace) for name in ('main.js', 'LICENSE.txt')), 'empty script/license')
    require(output.suffix == '.luoplugin', 'output extension must be .luoplugin')
    buffer = io.BytesIO()
    with zipfile.ZipFile(buffer, 'w', compression=zipfile.ZIP_DEFLATED) as archive:
        for name in FILES:
            archive.writestr(name, payload[name])
    require(buffer.tell() <= 5 * MIB, 'compressed package limit exceeded')
    # Exclusive creation preserves existing release artifacts on mistakes.
    with output.open('xb') as stream:
        stream.write(buffer.getvalue())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('source', type=Path, help='staging directory containing exactly three payload files')
    parser.add_argument('output', type=Path, help='new .luoplugin output path (must not exist)')
    args = parser.parse_args()
    try:
        package(args.source, args.output)
    except (OSError, ValueError, TypeError, KeyError, RecursionError) as error:
        print('Package rejected: ' + str(error), file=sys.stderr)
        return 1
    print('Created ' + str(args.output) + ' (host validation still required)')
    return 0


if __name__ == '__main__':
    sys.exit(main())
