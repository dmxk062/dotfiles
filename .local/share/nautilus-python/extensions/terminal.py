#!/usr/bin/env python
import os
from gi.repository import Nautilus, GObject
from typing import List
from urllib.parse import unquote

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

class TerminalMenu(GObject.GObject, Nautilus.MenuProvider):
    def open_term_for_dir(self, _: Nautilus.MenuItem, file: Nautilus.FileInfo) -> None:
        filepath = self.expand_uri(file)
        os.system(f"kitty --detach --directory='{filepath}'")

    def edit_term(self, _: Nautilus.MenuItem, files: list[Nautilus.FileInfo]) -> None:
        args = ""
        for file in files:
            filepath = self.expand_uri(file)
            args = f"{args} '{filepath}'"
        os.system(f"kitty --detach -- nvim -O {args}")

    @classmethod
    def expand_uri(cls, file: Nautilus.FileInfo):
        return file.get_location().get_path()


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
            textfiles = []
            for file in files:
                if file.get_mime_type() in TEXT_TYPES:
                    textfiles.append(file)
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

