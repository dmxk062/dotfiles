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
        filepath = unquote(file.get_uri()[7:])
        os.system(f"kitty --class=popup --detach --directory='{filepath}'")

    def edit_term(self, _: Nautilus.MenuItem, files: list[Nautilus.FileInfo]) -> None:
        args = ""
        for file in files:
            filepath = unquote(file.get_uri()[7:])
            args = f"{args} '{filepath}'"
        os.system(f"kitty --detach --class=popup -- nvim -O {args}")

    def open_lf(self, _: Nautilus.MenuItem, file: Nautilus.FileInfo) -> None:
        filepath = unquote(file.get_uri()[7:])
        os.system(f"kitty --class=popup --detach --directory='{filepath}' -- zsh -ic lf")


    def get_file_items(
        self,
        files: List[Nautilus.FileInfo],
    ) -> List[Nautilus.MenuItem]:
        top_menuitem = Nautilus.MenuItem(
            name="TerminalMenu::Terminal",
            label="Terminal",
            tip="",
            icon="",
        )

        submenu = Nautilus.Menu()
        menu_count = 0
        if len(files) == 1 and files[0].is_directory():
            open_folder_item = Nautilus.MenuItem(
                name="Terminal::terminal_open_submenu",
                label="Open In Terminal",
                tip="",
                icon="",
            )
            open_folder_item.connect("activate", self.open_term_for_dir, files[0])
            submenu.append_item(open_folder_item)
            open_lf_item = Nautilus.MenuItem(
                name="Terminal::terminal_lf_submenu",
                label="Open In Terminal File Manager",
                tip="",
                icon="",
            )
            open_lf_item.connect("activate", self.open_lf, files[0])
            submenu.append_item(open_lf_item)
            menu_count += 1
        else:
            textfiles = []
            for file in files:
                if file.get_mime_type() in TEXT_TYPES:
                    textfiles.append(file)
            if len(textfiles) > 0:
                edit_term_item = Nautilus.MenuItem(
                    name="Terminal::terminal_edit_submenu",
                    label="Edit In Terminal",
                    tip="",
                    icon="",
                )
                edit_term_item.connect("activate", self.edit_term, textfiles)
                submenu.append_item(edit_term_item)
                menu_count += 1


        if menu_count == 0:
            return []

        top_menuitem.set_submenu(submenu)

        return [
            top_menuitem,
        ]

    def get_background_items(
        self,
        current_folder: Nautilus.FileInfo,
    ) -> List[Nautilus.MenuItem]:
        openInItem = Nautilus.MenuItem(
            name="TerminalMenu::Terminal",
            label="Open in Terminal",
            tip="",
            icon="",
        )
        openInItem.connect("activate", self.open_term_for_dir, current_folder)
        return [
            openInItem,
        ]

