#!/usr/bin/env bash
# source: https://github.com/Paxxs/clash-skk/blob/main/scripts/update-rules.sh
set -euo pipefail

ROOT_URL="${ROOT_URL:-https://ruleset.skk.moe}"
OUT_DIR="${OUT_DIR:-.}"

links=$(python3 - "$ROOT_URL" <<'PY'
import sys
import urllib.request
from html.parser import HTMLParser

if len(sys.argv) < 2:
    raise SystemExit("missing base url")
base = sys.argv[1]
print(f"Fetching links from {base}...", file=sys.stderr)
req = urllib.request.Request(
    base,
    headers={
        "User-Agent": "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)",
        "Accept": "text/html,application/xhtml+xml",
    },
)
html = urllib.request.urlopen(req, timeout=30).read().decode("utf-8", errors="ignore")
links = []

class Parser(HTMLParser):
    def handle_starttag(self, tag, attrs):
        if tag != "a":
            return
        href = dict(attrs).get("href", "")
        if href.startswith("/Clash/") and href.endswith(".txt"):
            links.append(href)

Parser().feed(html)
for href in sorted(set(links)):
    print(href)
PY
)

while IFS= read -r path; do
    output_path="${OUT_DIR%/}${path}"
    echo "Downloading: ${ROOT_URL}${path}"
    echo "       Save: $output_path"
    mkdir -p "$(dirname "$output_path")"
    curl \
      --retry 5 \
      --retry-delay 2 \
      --retry-all-errors \
      --connect-timeout 15 \
      --max-time 120 \
      -fsSL \
      "${ROOT_URL}${path}" \
      -o "$output_path"
done <<< "$links"
