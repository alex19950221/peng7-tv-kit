"""Validate only the explicitly listed public files; never print matched secrets."""
from pathlib import Path, PurePosixPath
import hashlib
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parent.parent
FORBIDDEN_PARTS = {'.git', 'local', '.work', 'dist', '__pycache__'}
PATTERNS = {
    'private key': r'-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----',
    'GitHub token': r'\b(?:gh[pousr]_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{30,})',
    'cloud access key': r'\b(?:AKIA|ASIA)[A-Z0-9]{16}\b',
    'local user path': r'(?i)[A-Z]:[\\/](?:Users|codex)[\\/]',
    'LAN address': r'\b(?:192\.168\.\d{1,3}\.\d{1,3}|10\.\d{1,3}\.\d{1,3}\.\d{1,3}|172\.(?:1[6-9]|2\d|3[01])\.\d{1,3}\.\d{1,3})\b',
    'credential URL': r'https?://[^\s/]+:[^\s/@]+@',
    'URL token': r'(?i)[?&](?:token|secret|password|key)=[A-Za-z0-9_%+/-]{8,}',
}

def public_paths():
    names = [line.strip() for line in (ROOT / 'public-files.txt').read_text(encoding='utf-8').splitlines()
             if line.strip() and not line.startswith('#')]
    if len(names) != len(set(names)):
        raise ValueError('Duplicate public manifest entry')
    paths = []
    for name in names:
        rel = PurePosixPath(name)
        if rel.is_absolute() or '..' in rel.parts or any(p in FORBIDDEN_PARTS for p in rel.parts):
            raise ValueError('Unsafe public manifest path')
        path = ROOT / name
        if path.is_symlink() or not path.is_file() or not path.resolve().is_relative_to(ROOT):
            raise ValueError(f'Missing or unsafe file: {name}')
        if any(parent.is_symlink() for parent in path.parents if parent != ROOT.parent):
            raise ValueError('Symlink in public path')
        paths.append(path)
    return paths

def validate():
    paths = public_paths()
    failures = []
    # Binary screenshots cannot be covered by text scans. Publish only PNGs
    # whose exact bytes were visually reviewed and recorded in the manifest.
    review_path = ROOT / 'docs/images/reviewed.json'
    reviews = {}
    if review_path in paths:
        review_data = json.loads(review_path.read_text(encoding='utf-8'))
        reviews = {item['path']: item for item in review_data['screenshots']}
    for path in paths:
        name = path.relative_to(ROOT).as_posix()
        if path.suffix.lower() == '.png':
            data = path.read_bytes()
            review = reviews.get(name, {})
            if (not name.startswith('docs/images/')
                    or not data.startswith(b'\x89PNG\r\n\x1a\n')
                    or not data.endswith(b'\x00\x00\x00\x00IEND\xaeB`\x82')
                    or review.get('privacy_reviewed') is not True
                    or review.get('sha256') != hashlib.sha256(data).hexdigest()):
                failures.append(f'{name}: missing or mismatched screenshot review')
            continue
        text = path.read_text(encoding='utf-8')
        for label, pattern in PATTERNS.items():
            if re.search(pattern, text):
                failures.append(f'{name}: {label}')
        # Real credentials belong in ignored local files, never in a public example.
        for match in re.finditer(r'(?im)^\s*(?:password|storePassword|keyPassword)\s*[:=]\s*(\S+)', text):
            if not match.group(1).strip('\"\'').startswith('CHANGE_ME'):
                failures.append(f'{name}: non-placeholder credential field')
    lock = json.loads((ROOT / 'upstream.lock.json').read_text(encoding='utf-8'))
    patch = ROOT / lock['patch']
    if patch not in paths or hashlib.sha256(patch.read_bytes()).hexdigest() != lock['patch_sha256']:
        failures.append('Patch checksum mismatch')
    # Refuse tracked files outside the reviewed allowlist, even if .gitignore would hide them.
    if (ROOT / '.git').exists():
        tracked = subprocess.run(['git', '-C', str(ROOT), 'ls-files', '-z'], check=True, capture_output=True).stdout
        allowed = {p.relative_to(ROOT).as_posix() for p in paths}
        for name in tracked.decode('utf-8').split('\0'):
            if name and name not in allowed:
                failures.append(f'Unreviewed tracked file: {name}')
    if failures:
        raise ValueError('\n'.join(failures))
    return paths

if __name__ == '__main__':
    try:
        result = validate()
        print(f'PASS: {len(result)} public files; patch checksum, content and screenshot review checks passed.')
    except (ValueError, OSError, subprocess.CalledProcessError) as exc:
        raise SystemExit(str(exc))
