#!/usr/bin/env python3
"""
Generate a tree view of all available shortcuts from symbolic-hotkeys.json

Usage:
    python generate-tree.py [--format text|markdown] [--output FILE]

Formats:
    text     - Plain text list (default)
    markdown - Markdown formatted list
"""

import json
import argparse
from pathlib import Path
from typing import Any, Dict

def generate_text_tree(data: Dict[str, Any], include_ids: bool = True, include_dynamic: bool = True) -> str:
    """Generate a plain text hierarchical list."""
    lines = ["`darwin.symbolicHotkeys`"]
    categories = data.get('categories', {})

    for cat_key, cat_data in categories.items():
        cat_name = cat_data.get('name', cat_key)
        lines.append(f"  - `{cat_key}` (**{cat_name}**)")

        # Process shortcuts in category
        shortcuts = cat_data.get('shortcuts', {})
        subgroups = cat_data.get('subgroups', {})

        # Add shortcuts
        for shortcut_key, shortcut_data in shortcuts.items():
            name = shortcut_data.get('name', shortcut_key)
            id_str = f" (ID: {shortcut_data['id']})" if include_ids and 'id' in shortcut_data else ""
            dynamic_str = " [dynamic]" if include_dynamic and shortcut_data.get('dynamic') else ""
            lines.append(f"    - `{shortcut_key}` - **{name}**{id_str}{dynamic_str}")

        # Add subgroups
        for subgroup_key, subgroup_data in subgroups.items():
            subgroup_name = subgroup_data.get('name', subgroup_key)
            lines.append(f"    - `{subgroup_key}` (**{subgroup_name}**)")

            # Add shortcuts in subgroup
            for sub_key, sub_data in subgroup_data.get('shortcuts', {}).items():
                name = sub_data.get('name', sub_key)
                id_str = f" (ID: {sub_data['id']})" if include_ids and 'id' in sub_data else ""
                dynamic_str = " [dynamic]" if include_dynamic and sub_data.get('dynamic') else ""
                lines.append(f"      - `{sub_key}` - **{name}**{id_str}{dynamic_str}")

    return "\n".join(lines)


def generate_markdown_tree(data: Dict[str, Any], include_ids: bool = True, include_dynamic: bool = True) -> str:
    """Generate a markdown formatted hierarchical list."""
    lines = [
        "# darwin-symbolic-hotkeys Options Tree",
        "",
        f"Generated from version: {data.get('version', 'unknown')}",
        f"Total categories: {len(data.get('categories', {}))}",
        "",
    ]

    if data.get('dynamicShortcuts'):
        lines.extend([
            "> **Note**: Shortcuts marked with `[dynamic]` are dynamically created by macOS.",
            ""
        ])

    lines.append("## darwin.symbolicHotkeys")
    lines.append("")

    categories = data.get('categories', {})

    for cat_key, cat_data in categories.items():
        cat_name = cat_data.get('name', cat_key)
        lines.append(f"- **{cat_key}** ({cat_name})")

        shortcuts = cat_data.get('shortcuts', {})
        subgroups = cat_data.get('subgroups', {})

        for shortcut_key, shortcut_data in shortcuts.items():
            name = shortcut_data.get('name', shortcut_key)
            id_str = f" (ID: {shortcut_data['id']})" if include_ids and 'id' in shortcut_data else ""
            dynamic_str = " `[dynamic]`" if include_dynamic and shortcut_data.get('dynamic') else ""
            lines.append(f"  - `{shortcut_key}` - {name}{id_str}{dynamic_str}")

        for subgroup_key, subgroup_data in subgroups.items():
            subgroup_name = subgroup_data.get('name', subgroup_key)
            lines.append(f"  - **{subgroup_key}** ({subgroup_name})")

            for sub_key, sub_data in subgroup_data.get('shortcuts', {}).items():
                name = sub_data.get('name', sub_key)
                id_str = f" (ID: {sub_data['id']})" if include_ids and 'id' in sub_data else ""
                dynamic_str = " `[dynamic]`" if include_dynamic and sub_data.get('dynamic') else ""
                lines.append(f"    - `{sub_key}` - {name}{id_str}{dynamic_str}")

    # Add statistics
    total_shortcuts = 0
    dynamic_count = 0
    for cat in categories.values():
        shortcuts = cat.get('shortcuts', {})
        total_shortcuts += len(shortcuts)
        dynamic_count += sum(1 for s in shortcuts.values() if s.get('dynamic'))

        for subgroup in cat.get('subgroups', {}).values():
            sub_shortcuts = subgroup.get('shortcuts', {})
            total_shortcuts += len(sub_shortcuts)
            dynamic_count += sum(1 for s in sub_shortcuts.values() if s.get('dynamic'))

    lines.extend([
        "",
        "## Statistics",
        "",
        f"- Total shortcuts: {total_shortcuts}",
        f"- Dynamic shortcuts: {dynamic_count}",
        f"- Categories: {len(categories)}",
    ])

    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(
        description='Generate a tree view of all available shortcuts'
    )
    parser.add_argument(
        '--format',
        choices=['text', 'markdown'],
        default='text',
        help='Output format (default: text)'
    )
    parser.add_argument(
        '--output',
        type=str,
        help='Output file (default: stdout)'
    )
    parser.add_argument(
        '--no-ids',
        action='store_true',
        help='Do not include shortcut IDs'
    )
    parser.add_argument(
        '--no-dynamic',
        action='store_true',
        help='Do not mark dynamic shortcuts'
    )

    args = parser.parse_args()

    # Load data
    script_dir = Path(__file__).parent
    data_dir = script_dir.parent / 'data'
    json_path = data_dir / 'symbolic-hotkeys.json'

    if not json_path.exists():
        print(f"Error: {json_path} not found")
        print("Run parse-shortcuts.py first to generate the JSON file")
        return 1

    with open(json_path, 'r') as f:
        data = json.load(f)

    # Generate tree
    if args.format == 'markdown':
        output = generate_markdown_tree(
            data,
            include_ids=not args.no_ids,
            include_dynamic=not args.no_dynamic
        )
    else:
        output = generate_text_tree(
            data,
            include_ids=not args.no_ids,
            include_dynamic=not args.no_dynamic
        )

    # Write output
    if args.output:
        output_path = Path(args.output)
        with open(output_path, 'w') as f:
            f.write(output)
        print(f"Tree written to: {output_path}")
    else:
        print(output)

    return 0


if __name__ == '__main__':
    exit(main())
