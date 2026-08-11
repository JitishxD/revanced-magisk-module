#!/usr/bin/env bash
# Builds the Custom-branding adaptive icon folder from a single source image.
# Usage: ./make_icon_assets.sh custom_logo.jpg assets/jyt-icon [background-color]
set -euo pipefail

SRC="${1:?Usage: $0 <source-image> <output-dir> [bg-color]}"
OUT="${2:?Usage: $0 <source-image> <output-dir> [bg-color]}"
BG="${3:-white}"

if [ ! -f "$SRC" ]; then
  echo "Source image not found: $SRC" >&2
  exit 1
fi

# density label -> canvas size (px), per the patch's required dimensions
declare -A SIZES=(
  [mipmap-mdpi]=108
  [mipmap-hdpi]=162
  [mipmap-xhdpi]=216
  [mipmap-xxhdpi]=324
  [mipmap-xxxhdpi]=432
)

for dir in "${!SIZES[@]}"; do
  size="${SIZES[$dir]}"
  # Adaptive icons get masked into a circle/squircle/etc by the launcher,
  # so foreground content must stay inside a ~66% safe zone or it gets clipped.
  safe=$(( size * 66 / 100 ))
  mkdir -p "$OUT/$dir"

  # Background layer: solid color, full canvas, opaque.
  convert -size "${size}x${size}" "xc:${BG}" \
    "$OUT/$dir/morphe_adaptive_background_custom.png"

  # Foreground layer: logo scaled to fit the safe zone, centered on a
  # transparent canvas at full size.
  convert "$SRC" \
    -fuzz 8% -transparent white \
    -resize "${safe}x${safe}" \
    -background none -gravity center -extent "${size}x${size}" \
    "$OUT/$dir/morphe_adaptive_foreground_custom.png"

  echo "Wrote $OUT/$dir (${size}x${size}, safe zone ${safe}px)"
done

echo
echo "Done. Point patcher-args at: -OcustomIcon=$OUT"
echo "Note: no monochrome/notification icon generated (optional) - add manually if needed."
