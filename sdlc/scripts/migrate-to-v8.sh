#!/usr/bin/env bash
#
# migrate-to-v8.sh
# Migrates from v7.x (file-based ADRs) to v8.x (commit-based ADRs)
#
# What it does:
# - Detects existing docs/adr/*.md files
# - Archives them to docs/adr-archive/
# - Provides migration summary
#
# Exit codes:
#   0 - Migration complete (or no ADRs found)
#   1 - Error during migration

set -e

echo "🔄 SDLC Plugin v8.0.0 Migration"
echo ""
echo "This script migrates from file-based ADRs to commit-based ADRs."
echo ""

# Check if docs/adr/ exists
if [[ ! -d "docs/adr" ]]; then
  echo "✅ No existing ADR directory found. Nothing to migrate."
  echo ""
  echo "You're ready to use v8.0.0!"
  echo ""
  echo "Next steps:"
  echo "  - Run /sdlc:setup to install pre-commit hooks"
  echo "  - Use /arch (or /sdlc:arch) for architecture changes"
  echo ""
  exit 0
fi

# Count ADR files
adr_count=$(find docs/adr -name "*.md" -type f 2>/dev/null | wc -l)

if [[ "$adr_count" -eq 0 ]]; then
  echo "✅ ADR directory exists but is empty. Nothing to migrate."
  echo ""
  echo "You're ready to use v8.0.0!"
  echo ""
  echo "Next steps:"
  echo "  - Run /sdlc:setup to install pre-commit hooks"
  echo "  - Use /arch (or /sdlc:arch) for architecture changes"
  echo ""
  exit 0
fi

echo "📁 Found $adr_count ADR file(s) in docs/adr/"
echo ""
echo "These will be archived to docs/adr-archive/"
echo ""

# Ask for confirmation
read -p "Continue with migration? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Migration cancelled."
  exit 0
fi

# Create archive directory
mkdir -p docs/adr-archive

# Move ADR files
echo ""
echo "📦 Archiving ADR files..."
echo ""

find docs/adr -name "*.md" -type f | while read -r adr_file; do
  basename=$(basename "$adr_file")
  echo "  $adr_file → docs/adr-archive/$basename"
  mv "$adr_file" "docs/adr-archive/"
done

echo ""
echo "✅ Migration complete!"
echo ""
echo "📊 Summary:"
echo "  - $adr_count ADR file(s) archived to docs/adr-archive/"
echo "  - docs/adr/ directory preserved (empty)"
echo ""
echo "🎯 Next steps:"
echo ""
echo "1. Review docs/ARCHITECTURE.md (if it exists)"
echo "   - This is your living architecture document"
echo "   - Reference this in all code and documentation"
echo ""
echo "2. Run /sdlc:setup to install pre-commit hooks"
echo "   - Enforces architecture commit isolation"
echo "   - Validates ADR format in commit messages"
echo ""
echo "3. For architecture changes, use /arch or /sdlc:arch:"
echo "   /arch \"adopt event sourcing for core domain\""
echo ""
echo "4. Search for decision context in git history:"
echo "   git log --all --grep=\"Context and Problem\" docs/ARCHITECTURE.md"
echo ""
echo "📚 Migration guide: sdlc/MIGRATION-v8.md"
echo ""
