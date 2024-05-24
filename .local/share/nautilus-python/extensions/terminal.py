#!/usr/bin/env python
import os
import subprocess
from gi.repository import Nautilus, GObject
from typing import List
from urllib.parse import urlparse, unquote

TEXT_TYPES = (
    'text/plain',
    'text/markdown',
    'text/html',
    'text/css',
    'text/x-lisp',
    'text/x-shellscript',
    'text/javascript',
    'application/json',
    'application/xml',
    'application/xhtml+xml',
    'application/rss+xml',
    'application/atom+xml',
    'application/javascript',
    'application/ecmascript',
)

def launch_term(command: list[str], pwd: str) -> None:
    subprocess.run(["kitty", "--detach", f"--directory={pwd}", "--"] + command)

def open_uri_in_term(file: Nautilus.FileInfo, cmd=[]) -> None:
    if cmd != []:
        launch_term(cmd, "~")
    else:
        uri = urlparse(file.get_location().get_uri())
        path = unquote(uri.path)

        match uri.scheme:
            case "file":
                launch_term(cmd, path)
            case "sftp":
                pass
            case _:
                pass


class TerminalMenu(GObject.GObject, Nautilus.MenuProvider):
    def open_term_for_dir(self, _: Nautilus.MenuItem, file: Nautilus.FileInfo) -> None:
        open_uri_in_term(file)

    def edit_term(self, _: Nautilus.MenuItem, files: list[Nautilus.FileInfo]) -> None:
        files = [
                unquote(
                    urlparse(
                        f.get_location().get_uri()
                    ).path)
        for f in files]

        cmd = ["nvim"] + files
        open_uri_in_term('', cmd)



    def get_file_items(
        self,
        files: List[Nautilus.FileInfo],
    ) -> List[Nautilus.MenuItem]:
        if len(files) == 1 and files[0].is_directory():
            open_folder_item = Nautilus.MenuItem(
                name="Terminal::terminal_open_submenu",
                label="Open in Terminal",
                tip="",
                icon="",
            )
            open_folder_item.connect("activate", self.open_term_for_dir, files[0])
            return [open_folder_item]
        else:
            textfiles = [f for f in files if f.get_mime_type() in TEXT_TYPES]
            if len(textfiles) > 0:
                edit_term_item = Nautilus.MenuItem(
                    name="Terminal::terminal_edit_submenu",
                    label="Edit in Terminal",
                    tip="",
                    icon="",
                )
                edit_term_item.connect("activate", self.edit_term, textfiles)
                return [edit_term_item]

        return []

    def get_background_items(
        self,
        current_folder: Nautilus.FileInfo,
    ) -> List[Nautilus.MenuItem]:
        openInItem = Nautilus.MenuItem(
            name="TerminalMenu::terminal_open_menu",
            label="Open in Terminal",
            tip="",
            icon="",
        )
        openInItem.connect("activate", self.open_term_for_dir, current_folder)
        return [
            openInItem,
        ]

