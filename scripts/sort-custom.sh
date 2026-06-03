#!/usr/bin/env bash
set -euo pipefail

CUSTOM_DIR="${1:-custom}"

if [[ ! -d "$CUSTOM_DIR" ]]; then
  echo "Custom dir not found: $CUSTOM_DIR"
  exit 0
fi

find "$CUSTOM_DIR" -type f -print0 | while IFS= read -r -d '' file; do
  tmp="${file}.tmp"

  {
    sed -n '1,2p' "$file"
    sed '1,2d' "$file" | sort -u
  } > "$tmp"

  mv "$tmp" "$file"
done

