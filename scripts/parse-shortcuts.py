#!/usr/bin/env python3
"""
Parse macOS DefaultShortcutsTable.xml and generate symbolic-hotkeys.json

This script extracts shortcut definitions from the macOS keyboard settings XML
and generates a structured JSON file for use in the Nix module.

Usage:
    python parse-shortcuts.py

Output:
    ../data/symbolic-hotkeys.json
"""

import json
import plistlib
import re
from pathlib import Path
from typing import Any


def to_camel_case(s: str) -> str:
    """Convert a string to camelCase identifier."""
    # Remove "DO_NOT_LOCALIZE: " prefix if present
    s = re.sub(r'^DO_NOT_LOCALIZE:\s*', '', s)

    # Remove common suffixes/prefixes that don't add value
    s = re.sub(r'\s*\(AX_DESCRIPTION\)$', '', s)
    s = re.sub(r'\s*\(window management\)$', '', s)

    # Replace special characters with spaces
    s = re.sub(r'[/\-]', ' ', s)

    # Split into words
    words = s.split()

    if not words:
        return ''

    # Convert to camelCase
    result = words[0].lower()
    for word in words[1:]:
        result += word.capitalize()

    # Remove any remaining non-alphanumeric characters
    result = re.sub(r'[^a-zA-Z0-9]', '', result)

    return result


def clean_name(s: str) -> str:
    """Clean the display name by removing DO_NOT_LOCALIZE prefix."""
    return re.sub(r'^DO_NOT_LOCALIZE:\s*', '', s)


def parse_shortcut_element(element: dict) -> dict | None:
    """Parse a single shortcut element from the XML."""
    name = element.get('name', '')
    if not name:
        return None

    # Skip elements that are just containers or display-only
    node_class = element.get('node_class', '')
    if node_class == 'DisplayOnlyNode':
        return None

    # Skip elements without a symbolic hotkey ID
    hotkey_id = element.get('sybmolichotkey')  # Note: typo in Apple's XML
    if hotkey_id is None:
        # Check for nested elements (subgroups)
        nested = element.get('elements', [])
        if nested:
            return parse_group(element)
        return None

    result = {
        'id': hotkey_id,
        'name': clean_name(name),
        'nixName': to_camel_case(name),
    }

    # Add default key and modifier if present
    if 'key' in element:
        result['defaultKey'] = element['key']
    if 'modifier' in element:
        result['defaultModifier'] = element['modifier']
    if 'charKey' in element:
        result['defaultCharKey'] = element['charKey']

    # Add enabled state if explicitly set
    if 'enabled' in element:
        result['defaultEnabled'] = element['enabled']

    # Add slow symbolic hotkey if present (for double-tap shortcuts)
    if 'slow_sybmolichotkey' in element:
        result['slowId'] = element['slow_sybmolichotkey']

    # Add identifier if present
    if 'identifier' in element:
        result['identifier'] = element['identifier']

    return result


def parse_group(group: dict) -> dict | None:
    """Parse a group (subgroup) of shortcuts."""
    name = group.get('name', '')
    if not name:
        return None

    elements = group.get('elements', [])
    if not elements:
        return None

    shortcuts = {}
    for elem in elements:
        parsed = parse_shortcut_element(elem)
        if parsed:
            if 'shortcuts' in parsed:
                # This is a nested group
                nix_name = parsed.get('nixName', to_camel_case(elem.get('name', '')))
                shortcuts[nix_name] = parsed
            else:
                # This is a shortcut
                nix_name = parsed.get('nixName', '')
                if nix_name:
                    shortcuts[nix_name] = parsed

    if not shortcuts:
        return None

    return {
        'name': clean_name(name),
        'nixName': to_camel_case(name),
        'identifier': group.get('identifier', ''),
        'shortcuts': shortcuts,
    }


def parse_category(category: dict) -> dict | None:
    """Parse a top-level category from the XML."""
    name = category.get('name', '')
    identifier = category.get('identifier', '')

    if not name or not identifier:
        return None

    elements = category.get('elements', [])
    shortcuts = {}
    subgroups = {}

    for elem in elements:
        # Check if this is a subgroup (has nested elements but no sybmolichotkey)
        if 'elements' in elem and 'sybmolichotkey' not in elem:
            parsed = parse_group(elem)
            if parsed:
                nix_name = parsed.get('nixName', '')
                if nix_name:
                    subgroups[nix_name] = parsed
        else:
            parsed = parse_shortcut_element(elem)
            if parsed and 'id' in parsed:
                nix_name = parsed.get('nixName', '')
                if nix_name:
                    shortcuts[nix_name] = parsed

    result = {
        'name': clean_name(name),
        'nixName': to_camel_case(name),
        'identifier': identifier,
    }

    if shortcuts:
        result['shortcuts'] = shortcuts
    if subgroups:
        result['subgroups'] = subgroups

    return result


def main():
    script_dir = Path(__file__).parent
    data_dir = script_dir.parent / 'data'

    xml_path = data_dir / 'DefaultShortcutsTable.xml'
    output_path = data_dir / 'symbolic-hotkeys.json'

    if not xml_path.exists():
        print(f"Error: {xml_path} not found")
        print("Please copy the file from:")
        print("/System/Library/ExtensionKit/Extensions/KeyboardSettings.appex/Contents/Resources/en.lproj/DefaultShortcutsTable.xml")
        return 1

    # Parse the plist XML
    with open(xml_path, 'rb') as f:
        data = plistlib.load(f)

    # Parse all categories
    categories = {}
    for category in data:
        parsed = parse_category(category)
        if parsed:
            nix_name = parsed.get('nixName', '')
            if nix_name:
                categories[nix_name] = parsed

    # Build the output structure
    output = {
        'version': 'macOS 15.x (Sequoia)',
        'generatedFrom': 'DefaultShortcutsTable.xml',
        'note': 'Generated by parse-shortcuts.py. Do not edit manually.',
        'categories': categories,
    }

    # Write the JSON output
    with open(output_path, 'w') as f:
        json.dump(output, f, indent=2)

    print(f"Generated: {output_path}")

    # Print summary
    total_shortcuts = 0
    for cat_name, cat in categories.items():
        cat_count = len(cat.get('shortcuts', {}))
        for subgroup in cat.get('subgroups', {}).values():
            cat_count += len(subgroup.get('shortcuts', {}))
        total_shortcuts += cat_count
        print(f"  {cat_name}: {cat_count} shortcuts")

    print(f"Total: {total_shortcuts} shortcuts in {len(categories)} categories")

    return 0


if __name__ == '__main__':
    exit(main())
