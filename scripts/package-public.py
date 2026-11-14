"""Package the reviewed allowlist, excluding all Git history and local state."""
from pathlib import Path
import hashlib
import importlib.util
import zipfile

ROOT = Path(__file__).resolve().parent.parent
spec = importlib.util.spec_from_file_location('public_check', ROOT / 'scripts/check-public.py')
checker = importlib.util.module_from_spec(spec)
spec.loader.exec_module(checker)
paths = checker.validate()
destination = ROOT / 'dist'
destination.mkdir(exist_ok=True)
output = destination / 'peng7-tv-kit-source.zip'
with zipfile.ZipFile(output, 'w', compression=zipfile.ZIP_DEFLATED) as archive:
    for path in sorted(paths):
        archive.write(path, 'peng7-tv-kit/' + path.relative_to(ROOT).as_posix())
digest = hashlib.sha256(output.read_bytes()).hexdigest()
(destination / 'SHA256SUMS.txt').write_text(f'{digest}  {output.name}\n', encoding='utf-8')
print(f'Packaged {len(paths)} files: {output}')
print(f'SHA256: {digest}')
