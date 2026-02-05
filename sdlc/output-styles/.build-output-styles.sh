#!/bin/bash
set -euo pipefail

# Build output styles from templates
# Usage: ./.build-output-styles.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/.templates"
OUTPUT_DIR="$SCRIPT_DIR"

echo "Building output styles from templates..."

# Build sdlc-marvin.md
echo "  → sdlc-marvin.md"
cat "$TEMPLATES_DIR/personality-marvin.md" \
    "$TEMPLATES_DIR/orchestration-rules.md" \
    > "$OUTPUT_DIR/sdlc-marvin.md"

# Build sdlc-rules.md
echo "  → sdlc-rules.md"
cat "$TEMPLATES_DIR/personality-rules.md" \
    "$TEMPLATES_DIR/orchestration-rules.md" \
    > "$OUTPUT_DIR/sdlc-rules.md"

echo "✓ Output styles rebuilt successfully"
