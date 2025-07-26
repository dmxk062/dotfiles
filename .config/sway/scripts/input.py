#!/usr/bin/env python

import argparse, sys

import gi

gi.require_version("Gtk", "3.0")
gi.require_version("GtkLayerShell", "0.1")

from gi.repository import Gtk, GtkLayerShell as LayerShell
from gi.repository import Gdk


class State:
    def __init__(self, max_length: int, numbers_only: bool, label: Gtk.Label):
        self.chars = []
        self.count = 0
        self.max_length = max_length
        self.label = label
        self.numeric = numbers_only

    def put(self, char):
        self.chars.append(char)
        self.count += 1
        if self.max_length > 0:
            if self.count == self.max_length:
                self.quit(0)
        self.update()

    def backspace(self):
        if self.count > 0:
            self.count -= 1
            self.chars.pop()
        self.update()

    def backword(self):
        if self.count > 0:
            while len(self.chars) > 0 and not self.chars.pop().isspace():
                pass
            self.count = len(self.chars)

        self.update()

    def update(self):
        self.label.set_label("".join(self.chars))

    def quit(self, success):
        if success:
            print("".join(self.chars))
        Gtk.main_quit()
        sys.exit(0 if success else 1)

    def on_key(self, win: Gtk.Window, ev: Gdk.EventKey):
        text = chr(Gdk.keyval_to_unicode(ev.keyval))
        if ev.keyval == Gdk.KEY_Escape:
            self.quit(False)
        elif ev.keyval == Gdk.KEY_Return:
            self.quit(True)
        elif ev.keyval == Gdk.KEY_BackSpace:
            self.backspace()
        elif (ev.state & Gdk.ModifierType.CONTROL_MASK):
            if ev.keyval == Gdk.KEY_w or ev.keyval == Gdk.KEY_W:
                self.backword()
            elif ev.keyval == Gdk.KEY_u or ev.keyval == Gdk.KEY_U:
                self.chars = []
                self.count = 0
                self.update()
        elif self.numeric:
            if text.isnumeric():
                self.put(text)
        elif text.isascii() and text.isprintable():
            self.put(text)


css = b"""
label {
    font-size: 3rem;
}
box {
    border-radius: 20px;
    padding: 1rem;
    margin: 1rem;
    box-shadow: rgba(0, 0, 0, 0.3) 0px 4px 6px;
}
window decoration {
    background: transparent;
}
"""

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-l", "--max-length", type=int, default=1)
    parser.add_argument("-t", "--title", type=str)
    parser.add_argument("-n", "--numeric", action="store_true")
    args = parser.parse_args()

    window = Gtk.Window()
    LayerShell.init_for_window(window)
    LayerShell.set_layer(window, LayerShell.Layer.OVERLAY)
    LayerShell.set_keyboard_mode(window, LayerShell.KeyboardMode.EXCLUSIVE)

    box = Gtk.Box()
    label = Gtk.Label()

    provider = Gtk.CssProvider()
    provider.load_from_data(css)
    context = Gtk.StyleContext()
    screen = Gdk.Screen.get_default()
    context.add_provider_for_screen(
        screen, provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
    )

    prompt = Gtk.Label(label=f"{args.title or "Input"}{"[0-9]" if args.numeric else ""}: ")
    box.pack_start(prompt, False, False, 0)
    box.add(label)
    window.add(box)

    state = State(args.max_length, args.numeric, label)

    window.connect("key-press-event", state.on_key)

    window.show_all()
    Gtk.main()
