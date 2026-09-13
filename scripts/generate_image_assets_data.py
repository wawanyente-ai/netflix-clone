# ============================================================
# Assets
# ============================================================

GROUPS = {
    "Brand": [
        "NetflixLogoLarge.svg",
        "NetflixWordmark.svg",
        "NetflixLogoSmall.svg",
        "NetflixLogoSingleBadge.svg",
    ],

    "Icons": [
        "Add.svg",
        "Brightness.svg",
        "Close.svg",
        "DownloadAction.svg",
        "DownloadNavigation.svg",
        "Error.svg",
        "Home.svg",
        "Info.svg",
        "Like.svg",
        "LockClosed.svg",
        "LockOpen.svg",
        "Mirror.svg",
        "Pause.svg",
        "PlayStacked.svg",
        "Play.svg",
        "Search.svg",
        "Share.svg",
        "SkipBackward.svg",
        "SkipForward.svg",
        "Smile.svg",
        "Speed.svg",
        "Subtitles.svg",
        "User.svg",
    ],

    "UserVariants": [
        "UserPink.svg",
        "UserTurquoise.svg",
        "UserTurquoise1.svg",
        "UserBlue.svg",
    ],
}


# ============================================================
# Contents.json
# ============================================================

def create_contents_json():
    return {
        "images": [
            {
                "filename": "image.svg",
                "idiom": "universal",
                "scale": "1x",
            }
        ],
        "info": {
            "author": "xcode",
            "version": 1,
        },
    }