#!/bin/bash
# Export barista.p8 to HTML and place in docs/ for GitHub Pages
set -e

cd "$(dirname "$0")"

mkdir -p docs

pico8 -x barista.p8 -export docs/index.html

echo "Exported to docs/index.html"
echo "Commit and push to deploy to GitHub Pages."
