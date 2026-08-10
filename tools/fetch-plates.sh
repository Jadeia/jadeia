#!/usr/bin/env bash
#
# fetch-plates.sh — download the four Metropolitan Museum plates and optimise
# them for the web. Run once from anywhere:
#
#     bash tools/fetch-plates.sh
#
# Plate I (Aberdeen Bestiary, MS 24 f.66r) is not on an open API and must be
# saved by hand; this script tells you where to put it and checks for it at the
# end. Everything is written to assets/img/plates/ with the exact filenames the
# HTML already references.
#
# Optimisation uses ImageMagick if it is installed (`brew install imagemagick`,
# `apt install imagemagick`), and macOS `sips` otherwise. With neither, the
# full-resolution originals are kept and you are warned.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/assets/img/plates"
API="https://collectionapi.metmuseum.org/public/collection/v1/objects"

MAX_WIDTH=1600      # px on the long edge — plenty for a single-column layout
QUALITY=82

mkdir -p "$OUT"

# objectID|output filename|human label
PLATES=(
  "387574|plate-ii-durer-saint-george-and-the-dragon.jpg|Plate II — Saint George and the Dragon"
  "368340|plate-iii-durer-saint-michael-fighting-the-dragon.jpg|Plate III — Saint Michael Fighting the Dragon"
  "391133|plate-iv-durer-saint-george-standing.jpg|Plate IV — Saint George Standing"
  "388149|plate-v-durer-saint-george-slaying-the-dragon.jpg|Plate V — Saint George Slaying the Dragon"
)

json_field() {
  # json_field <field> — read stdin, print the string value of a top-level field
  if command -v python3 >/dev/null 2>&1; then
    python3 -c 'import json,sys; print(json.load(sys.stdin).get(sys.argv[1], ""))' "$1"
  else
    sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" | head -n 1
  fi
}

optimise() {
  local file="$1"
  if command -v magick >/dev/null 2>&1; then
    magick "$file" -resize "${MAX_WIDTH}x${MAX_WIDTH}>" -strip -interlace Plane \
      -quality "$QUALITY" "$file"
  elif command -v convert >/dev/null 2>&1; then
    convert "$file" -resize "${MAX_WIDTH}x${MAX_WIDTH}>" -strip -interlace Plane \
      -quality "$QUALITY" "$file"
  elif command -v sips >/dev/null 2>&1; then
    sips --resampleHeightWidthMax "$MAX_WIDTH" "$file" >/dev/null
  else
    echo "    ! no ImageMagick or sips found — keeping the full-resolution file"
    return 0
  fi
}

echo "Fetching plates into $OUT"
echo

for row in "${PLATES[@]}"; do
  IFS='|' read -r id name label <<< "$row"
  echo "  $label"

  meta="$(curl -fsSL "$API/$id")"
  url="$(printf '%s' "$meta" | json_field primaryImage)"
  public="$(printf '%s' "$meta" | json_field isPublicDomain)"

  if [ -z "$url" ]; then
    echo "    ! the Met returned no primaryImage for object $id — open"
    echo "      https://www.metmuseum.org/art/collection/search/$id and save it by hand"
    continue
  fi
  if [ "$public" = "False" ] || [ "$public" = "false" ]; then
    echo "    ! object $id is no longer flagged public domain — skipping"
    continue
  fi

  curl -fsSL "$url" -o "$OUT/$name"
  optimise "$OUT/$name"
  echo "    -> $name ($(du -h "$OUT/$name" | cut -f1))"
done

echo
BESTIARY="$OUT/plate-i-aberdeen-bestiary-f66r.jpg"
if [ -f "$BESTIARY" ]; then
  optimise "$BESTIARY"
  echo "  Plate I — Aberdeen Bestiary: present ($(du -h "$BESTIARY" | cut -f1))"
else
  echo "  Plate I — Aberdeen Bestiary: MISSING."
  echo "    Save the folio image from https://www.abdn.ac.uk/bestiary/ms24/f66r to:"
  echo "      $BESTIARY"
  echo "    then re-run this script to optimise it."
fi

echo
echo "Done. Preview with:  python3 -m http.server 8000 --directory \"$ROOT\""
