#!/usr/bin/env python3

import json
import shutil
from pathlib import Path

from generate_image_assets_data import GROUPS, create_contents_json


# ============================================================
# Paths
# ============================================================

PROJECT_ROOT = Path(__file__).resolve().parent.parent

SOURCE = (
    Path.home()
    / "Downloads"
    / "Netflix UI Kit (Mobile iOS) (Community)"
)

ASSETS = next(
    PROJECT_ROOT.rglob("Assets.xcassets"),
    None,
)

if ASSETS is None:
    raise FileNotFoundError(
        "Could not find 'Assets.xcassets'. "
        "Run this script from the project root."
    )


# ============================================================
# Generate Image Set
# ============================================================

def create_image_set(
    group: str,
    filename: str,
):
    source = SOURCE / filename

    if not source.exists():
        print(f"⚠️  Missing source: {filename}")
        return False

    asset_name = source.stem

    image_set = (
        ASSETS
        / group
        / f"{asset_name}.imageset"
    )

    # Remove existing image set
    if image_set.exists():
        shutil.rmtree(image_set)

    # Create fresh image set
    image_set.mkdir(
        parents=True,
        exist_ok=True,
    )

    # Copy SVG
    destination = image_set / "image.svg"

    shutil.copy2(
        source,
        destination,
    )

    # Generate Contents.json
    contents = image_set / "Contents.json"

    contents.write_text(
        json.dumps(
            create_contents_json(),
            indent=2,
        ) + "\n",
        encoding="utf-8",
    )

    print(
        f"✓ {group}/{asset_name}.imageset"
    )

    return True


# ============================================================
# Cleanup Group
# ============================================================

def cleanup_group(
    group: str,
    expected_files: list[str],
):
    group_path = ASSETS / group

    if not group_path.exists():
        return

    expected_assets = {
        Path(filename).stem
        for filename in expected_files
    }

    for image_set in group_path.glob("*.imageset"):
        asset_name = image_set.stem

        if asset_name not in expected_assets:
            print(
                f"🗑  Removing stale asset: "
                f"{group}/{image_set.name}"
            )

            shutil.rmtree(image_set)


# ============================================================
# Main
# ============================================================

def main():
    print("==========================================")
    print("       Generating Xcode Image Assets")
    print("==========================================")
    print()

    print(f"Source : {SOURCE}")
    print(f"Assets : {ASSETS}")
    print()

    if not SOURCE.exists():
        raise FileNotFoundError(
            f"Could not find source directory:\n{SOURCE}"
        )

    total = 0

    # --------------------------------------------------------
    # Generate groups
    # --------------------------------------------------------

    for group, files in GROUPS.items():
        print(f"[{group}]")

        # Remove assets that are no longer in GROUPS
        cleanup_group(
            group,
            files,
        )

        # Generate assets
        for filename in files:
            created = create_image_set(
                group,
                filename,
            )

            if created:
                total += 1

        print()

    # --------------------------------------------------------
    # Finish
    # --------------------------------------------------------

    print("==========================================")
    print(
        f"Done! Generated {total} image assets."
    )
    print("==========================================")


if __name__ == "__main__":
    main()