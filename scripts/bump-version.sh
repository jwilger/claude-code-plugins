#!/usr/bin/env bash
set -euo pipefail

# bump-version.sh — Propagate a new sdlc plugin version to all files that embed it.
#
# Usage: ./scripts/bump-version.sh <new-version>
#
# Source of truth: sdlc/.claude-plugin/plugin.json
# Targets updated:
#   1. sdlc/.claude-plugin/plugin.json   (jq)
#   2. .claude-plugin/marketplace.json   (jq — sdlc entry only)
#   3. sdlc/commands/setup.md            (sed — all occurrences)
#   4. sdlc/commands/start.md            (sed — all occurrences)
#   5. sdlc/commands/work.md             (sed — all occurrences)
#   6. sdlc/README.md                    (sed — line 1 heading only)
#   7. CLAUDE.md                         (sed — sdlc Plugin heading only)

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

usage() {
  echo "Usage: $0 <new-version>"
  echo "  e.g. $0 20.0.0"
  exit 1
}

# --- Validate args -----------------------------------------------------------

if [[ $# -ne 1 ]]; then
  usage
fi

NEW_VERSION="$1"

if ! [[ "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: Version must be semver (e.g. 20.0.0), got: $NEW_VERSION"
  exit 1
fi

# --- Read current version -----------------------------------------------------

PLUGIN_JSON="$REPO_ROOT/sdlc/.claude-plugin/plugin.json"

if [[ ! -f "$PLUGIN_JSON" ]]; then
  echo "Error: $PLUGIN_JSON not found"
  exit 1
fi

OLD_VERSION="$(jq -r '.version' "$PLUGIN_JSON")"

if [[ -z "$OLD_VERSION" || "$OLD_VERSION" == "null" ]]; then
  echo "Error: Could not read version from $PLUGIN_JSON"
  exit 1
fi

if [[ "$OLD_VERSION" == "$NEW_VERSION" ]]; then
  echo "Version is already $NEW_VERSION — nothing to do."
  exit 0
fi

# Escape dots for sed patterns
OLD_ESC="${OLD_VERSION//./\\.}"
NEW_ESC="${NEW_VERSION//./\\.}"

echo "Bumping sdlc plugin: $OLD_VERSION → $NEW_VERSION"
echo ""

# --- 1. plugin.json ----------------------------------------------------------

echo "  1/7  sdlc/.claude-plugin/plugin.json"
jq --arg v "$NEW_VERSION" '.version = $v' "$PLUGIN_JSON" > "$PLUGIN_JSON.tmp" \
  && mv "$PLUGIN_JSON.tmp" "$PLUGIN_JSON"

# --- 2. marketplace.json -----------------------------------------------------

MARKETPLACE="$REPO_ROOT/.claude-plugin/marketplace.json"
echo "  2/7  .claude-plugin/marketplace.json"
jq --arg v "$NEW_VERSION" \
  '(.plugins[] | select(.name == "sdlc")).version = $v' \
  "$MARKETPLACE" > "$MARKETPLACE.tmp" \
  && mv "$MARKETPLACE.tmp" "$MARKETPLACE"

# --- 3. setup.md (all occurrences) -------------------------------------------

SETUP_MD="$REPO_ROOT/sdlc/commands/setup.md"
echo "  3/7  sdlc/commands/setup.md"
sed -i "s/$OLD_ESC/$NEW_VERSION/g" "$SETUP_MD"

# --- 4. start.md (all occurrences) -------------------------------------------

START_MD="$REPO_ROOT/sdlc/commands/start.md"
echo "  4/7  sdlc/commands/start.md"
sed -i "s/$OLD_ESC/$NEW_VERSION/g" "$START_MD"

# --- 5. work.md (all occurrences) --------------------------------------------

WORK_MD="$REPO_ROOT/sdlc/commands/work.md"
echo "  5/7  sdlc/commands/work.md"
sed -i "s/$OLD_ESC/$NEW_VERSION/g" "$WORK_MD"

# --- 6. README.md (line 1 only) ----------------------------------------------

README_MD="$REPO_ROOT/sdlc/README.md"
echo "  6/7  sdlc/README.md  (line 1)"
sed -i "1s/$OLD_ESC/$NEW_VERSION/" "$README_MD"

# --- 7. CLAUDE.md (section heading only) -------------------------------------

CLAUDE_MD="$REPO_ROOT/CLAUDE.md"
echo "  7/7  CLAUDE.md  (sdlc Plugin heading)"
sed -i "s/### sdlc Plugin (v$OLD_ESC)/### sdlc Plugin (v$NEW_VERSION)/" "$CLAUDE_MD"

# --- Summary ------------------------------------------------------------------

echo ""
echo "Done.  $OLD_VERSION → $NEW_VERSION"
echo ""
echo "Verify with:  git diff"
echo "Then commit when ready."
