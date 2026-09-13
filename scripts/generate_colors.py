import json
import os

from generate_colors_data import ASSETS_PATH, COLORS


# ============================================================
# Helpers
# ============================================================

def hex_to_components(hex_color: str) -> dict:
    """
    Convert HEX color to Xcode asset components.

    Example:
        #D22F26
        ->
        {
            "red": "0.824",
            "green": "0.184",
            "blue": "0.149",
            "alpha": "1.000"
        }
    """

    hex_color = hex_color.strip().lstrip("#")

    if len(hex_color) != 6:
        raise ValueError(
            f"Invalid HEX color: #{hex_color}. "
            "Expected format #RRGGBB."
        )

    try:
        red = int(hex_color[0:2], 16) / 255
        green = int(hex_color[2:4], 16) / 255
        blue = int(hex_color[4:6], 16) / 255
    except ValueError:
        raise ValueError(
            f"Invalid HEX color: #{hex_color}."
        )

    return {
        "red": f"{red:.3f}",
        "green": f"{green:.3f}",
        "blue": f"{blue:.3f}",
        "alpha": "1.000",
    }


def create_color_contents(hex_color: str) -> dict:
    """
    Create the Contents.json structure for an Xcode Color Set.
    """

    return {
        "colors": [
            {
                "idiom": "universal",
                "color": {
                    "color-space": "srgb",
                    "components": hex_to_components(hex_color),
                },
            }
        ],
        "info": {
            "author": "xcode",
            "version": 1,
        },
    }


def create_directory(path: str):
    """
    Create directory if it doesn't exist.
    """

    os.makedirs(path, exist_ok=True)


def write_json(path: str, data: dict):
    """
    Write JSON with Xcode-friendly formatting.
    """

    with open(path, "w", encoding="utf-8") as file:
        json.dump(
            data,
            file,
            indent=2,
        )
        file.write("\n")


def create_color_set(
    group_name: str,
    color_name: str,
    hex_color: str,
):
    """
    Create or update:

        Assets.xcassets/
        └── Group/
            └── Color.colorset/
                └── Contents.json
    """

    group_path = os.path.join(
        ASSETS_PATH,
        group_name,
    )

    color_set_path = os.path.join(
        group_path,
        f"{color_name}.colorset",
    )

    contents_path = os.path.join(
        color_set_path,
        "Contents.json",
    )

    create_directory(color_set_path)

    contents = create_color_contents(hex_color)

    write_json(
        contents_path,
        contents,
    )

    print(
        f"✓ {group_name}/{color_name} "
        f"-> {hex_color}"
    )


# ============================================================
# Main
# ============================================================

def main():
    print("Generating Xcode colors...")
    print()

    # Make sure Assets.xcassets exists
    if not os.path.isdir(ASSETS_PATH):
        raise FileNotFoundError(
            f"Could not find '{ASSETS_PATH}'. "
            "Run this script from the project root."
        )

    total_colors = 0

    for group_name, colors in COLORS.items():

        print(f"[{group_name}]")

        for color_name, hex_color in colors.items():

            create_color_set(
                group_name=group_name,
                color_name=color_name,
                hex_color=hex_color,
            )

            total_colors += 1

        print()

    print(
        f"Done! Generated {total_colors} color sets."
    )


if __name__ == "__main__":
    main()