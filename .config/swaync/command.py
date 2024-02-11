#!/usr/bin/env python

import os, sys
import gi
gi.require_version("Gtk", "4.0")
gi.require_version("Notify", "0.7")
gi.require_version("Adw", "1")
from gi.repository import Gtk, Gio, GLib, Notify, Adw

APPLICATION_ID="com.github.dmxk062.pyshell.commands"

class CommandApp(Adw.Application):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.connect("activate", self.on_activate)


    def on_activate(self, app):
        self.win = AppWindow(application=app)
        self.win.present()

class AppWindow(Adw.ApplicationWindow):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        self.set_title("System Commands")
        self.set_default_size(600, 400)

        self.toolbarView = Adw.ToolbarView()

        self.headerBar = Adw.HeaderBar()
        self.toolbarView.add_top_bar(self.headerBar)

        self.commands = CommandList()
        self.toolbarView.set_content(self.commands)

        self.set_content(self.toolbarView)


class CommandInput(Adw.EntryRow):
    def __init__(self, title="Command"):
        super().__init__(title=title, hexpand=True)

        self.runButton = Gtk.Button(label="test")
        self.add_suffix(self.runButton)

class CommandList(Gtk.Box):
    def __init__(self):
        super().__init__(hexpand=True)
        self.listbox = Adw.PreferencesGroup(halign=Gtk.Align.CENTER)
        self.clamp   = Adw.Clamp()
        self.append(self.clamp)
        self.clamp.set_child(self.listbox)
        self.inputField = CommandInput()
        self.inputField1 = CommandInput()
        self.listbox.add(self.inputField)
        self.listbox.add(self.inputField1)



app = CommandApp(application_id=APPLICATION_ID)
app.run(sys.argv)

