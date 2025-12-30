#!/usr/bin/env bash
# Update shortcut data from macOS system files

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DATA_DIR="$SCRIPT_DIR/../data"

SYSTEM_DIR="/System/Library/ExtensionKit/Extensions/KeyboardSettings.appex/Contents/Resources"

echo "Updating darwin-symbolic-hotkeys data..."

# Copy XML
echo "1. Copying DefaultShortcutsTable.xml..."
if [ -f "$SYSTEM_DIR/en.lproj/DefaultShortcutsTable.xml" ]; then
    cp "$SYSTEM_DIR/en.lproj/DefaultShortcutsTable.xml" "$DATA_DIR/"
    echo "   ✓ XML copied"
else
    echo "   ✗ Error: XML file not found"
    exit 1
fi

# Extract localization
echo "2. Extracting localization..."
if [ -f "$SYSTEM_DIR/DefaultShortcutsTable.loctable" ]; then
    plutil -convert json -o - "$SYSTEM_DIR/DefaultShortcutsTable.loctable" | jq '.en' > "$DATA_DIR/localization.json"
    echo "   ✓ Localization extracted ($(jq 'length' "$DATA_DIR/localization.json") strings)"
else
    echo "   ✗ Error: loctable file not found"
    exit 1
fi

# Regenerate JSON
echo "3. Regenerating symbolic-hotkeys.json..."
cd "$SCRIPT_DIR/.."
python3 scripts/parse-shortcuts.py

echo ""
echo "✓ Update complete!"
echo "  Review changes with: git diff data/"
echo ""
echo "Optional: Generate shortcuts tree for documentation"
echo "  python3 scripts/generate-tree.py --format markdown --output SHORTCUTS_TREE.md"

