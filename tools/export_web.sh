#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
mkdir -p build/web
if [ ! -f .export_templates/web_nothreads_release.zip ]; then
  python3 tools/fetch_web_template.py
fi
godot --headless --path . --editor --import --quit
godot --headless --path . --export-release Web build/web/index.html
cp assets/ui/favicon.svg build/web/favicon.svg
cp assets/covers/little-knights-cover-v1.png build/web/cover.png
python3 - <<'PY'
from pathlib import Path
import zipfile, hashlib
root=Path("build/web")
pack=root/"index.pck"
versioned="index."+hashlib.sha256(pack.read_bytes()).hexdigest()[:12]+".pck"
for old in root.glob("index.*.pck"):
 old.unlink()
pack.rename(root/versioned)
page=root/"index.html"
html=page.read_text().replace('"index.pck"', '"'+versioned+'"')
html=html.replace('const config = {', 'const config = {"mainPack":"'+versioned+'",',1)
page.write_text(html)
with zipfile.ZipFile('build/little-knights-web.zip','w',zipfile.ZIP_DEFLATED) as archive:
 for path in Path('build/web').iterdir():
  if path.is_file() and path.suffix!='.import':archive.write(path,path.name)
 if Path('build/WEB-README.txt').exists():archive.write('build/WEB-README.txt','README.txt')
PY
