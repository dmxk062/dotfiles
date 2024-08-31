#!/usr/bin/env python

from urllib.parse import unquote, urlparse
from gi.repository import GObject, Nautilus, Gio
import os
import subprocess

SUPPORTED_MIMETYPES = {
    "image/jpeg",
    "image/png",
    "image/gif",
    "image/pnm",
    "image/tiff",
    "image/webp",
    "image/bmp",
}

CONFIG_DIR = os.getenv("XDG_CONFIG_HOME") or os.getenv("HOME") + "/.config"
WALLPAPER_PATH = CONFIG_DIR + "/background/wall"
LOCKSCREEN_PATH = CONFIG_DIR + "/background/lock"


def get_path(file):
    uri = urlparse(file.get_location().get_uri())
    if uri.scheme != "file":
        return None

    return unquote(uri.path)


def set_as_lock(ctx, file):
    path = get_path(file)
    if path is None:
        return

    os.unlink(LOCKSCREEN_PATH)
    os.link(path, LOCKSCREEN_PATH)


def set_as_wall(ctx, file):
    path = get_path(file)
    if path is None:
        return

    os.unlink(WALLPAPER_PATH)
    os.link(path, WALLPAPER_PATH)

    subprocess.run(
        [
            "swww",
            "img",
            "-t",
            "grow",
            "--transition-pos=bottom",
            "--transition-duration=1.2",
            "--transition-fps=60",
            WALLPAPER_PATH
        ]
    )


class SwwwWallpaperMenu(GObject.GObject, Nautilus.MenuProvider):
    def get_file_items(self, files: list[Nautilus.FileInfo]) -> list[Nautilus.MenuItem]:
        if len(files) != 1 or files[0].get_mime_type() not in SUPPORTED_MIMETYPES:
            return []

        lockscreen_item = Nautilus.MenuItem(
            name="SwwwWallpaperMenu::set_as::lockscreen", label="Set as Lockscreen"
        )
        lockscreen_item.connect("activate", set_as_lock, files[0])
        wallpaper_item = Nautilus.MenuItem(
            name="SwwwWallpaperMenu::set_as::wallpaper", label="Set as Wallpaper"
        )
        wallpaper_item.connect("activate", set_as_wall, files[0])

        return [wallpaper_item, lockscreen_item]

    def get_background_items(
        self, files: list[Nautilus.FileInfo]
    ) -> list[Nautilus.MenuItem]:
        return []
