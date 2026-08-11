#!/usr/bin/env bash
# Builds the Change-header asset folder from a single source image.
# Usage: ./make_header_assets.sh custom_logo.jpg assets/jyt-header
set -euo pipefail

SRC="${1:?Usage: $0 <source-image> <output-dir>}"
OUT="${2:?Usage: $0 <source-image> <output-dir>}"

if [ ! -f "$SRC" ]; then
  echo "Source image not found: $SRC" >&2
  exit 1
fi

# density label -> width x height (px), per the patch's required dimensions
declare -A SIZES=(
  [drawable-hdpi]="194x72"
  [drawable-xhdpi]="258x96"
  [drawable-xxhdpi]="387x144"
  [drawable-xxxhdpi]="512x192"
)

for dir in "${!SIZES[@]}"; do
  size="${SIZES[$dir]}"
  mkdir -p "$OUT/$dir"

  # Fit inside the exact box on a transparent canvas (no stretching/cropping),
  # convert to PNG, and drop the .jpg's white background so it isn't a white
  # box on top of YouTube's real background.
  convert "$SRC" \
    -fuzz 8% -transparent white \
    -resize "${size}" \
    -background none -gravity center -extent "${size}" \
    "$OUT/$dir/morphe_header_custom_dark.png"

  cp "$OUT/$dir/morphe_header_custom_dark.png" "$OUT/$dir/morphe_header_custom_light.png"

  echo "Wrote $OUT/$dir/morphe_header_custom_{dark,light}.png (${size})"
done

echo
echo "Done. Point patcher-args at: -Ocustom=$OUT"
