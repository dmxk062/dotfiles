#!/usr/bin/env python

import asyncio
import signal
import subprocess
import os
import sys
import time
import threading
import queue
import math

from utils import get_output
from eww import update_eww, set_window, CONFIGS
import hypr
from controller import Controller, Led, query_devices, KEYS, JOYSTICK, EVENTS

from enum import Enum

LOCKFILE="/tmp/eww/state/gaming/joymode"




#left for  more precise movements
SPEED_DIVIDER=2000
SCROLL_DIVIDER=15000
MOUSE_DELAY=0.02

BUTTON_DOWN = 0x40
BUTTON_UP   = 0x80

class Modes(Enum):
    GAME = 'game'
    DESKTOP = 'desktop'







def normalize_mouse(x: int, factor=2500) -> int:
    if abs(x) < 18000:
        return x // (factor * 3)
    elif abs(x) < 25000:
        return x // (factor * 2)
    else:
        return x // factor

def move_mouse(x: int, y: int) -> None:
    xval = normalize_mouse(x)
    yval = normalize_mouse(y)
    subprocess.Popen(["ydotool", "mousemove", "-x", str(xval), "-y", str(yval)], stdout=subprocess.DEVNULL) 

def move_wheel(x: int, y: int) -> None:
    xval = math.pow(abs(x), 1/4)//3
    yval = math.pow(abs(y), 1/4)//3
    if y > 0:
        yval = -yval
    if x < 0:
        xval = -xval
    subprocess.Popen(["ydotool", "mousemove", "-w", "-x", str(xval), "-y", str(yval)], stdout=subprocess.DEVNULL) 

def set_click(btn: int, state: int):
    if bool(state):
        btn = btn + BUTTON_DOWN
    else:
        btn = btn + BUTTON_UP
    subprocess.Popen(["ydotool", "click", str(hex(btn))], stdout=subprocess.DEVNULL)

def set_press(btn: int, state: int) -> None:
    flag = ":1" if bool(state) else ":0"
    subprocess.Popen(["ydotool", "key", f"{btn}{flag}"], stdout=subprocess.DEVNULL)



class ControllerMonitor:

    def __init__(self, dev: Controller, hypr_socket: hypr.HyprctlSocket):
        self.saved_cursor = ("volantes_light_cursor", 24)
        self.mode_changes = {
            "desktop": self.desktop_mode,
            "game":    self.game_mode
            }
        self.mode_handles = {
            "desktop": self.handle_desktop,
            "game":    self.handle_game
            }
        self.controller = dev
        self.socket = hypr_socket

        self.joysticks = { JOYSTICK.LEFT_VERTICAL: 0, JOYSTICK.LEFT_HORIZONTAL: 0,
                   JOYSTICK.RIGHT_VERTICAL: 0, JOYSTICK.RIGHT_HORIZONTAL: 0}

        self.mode    = Modes.GAME
        self.oldmode = Modes.GAME
        self.pressed = { KEYS.UP: False, KEYS.DOWN: False, KEYS.LEFT: False, KEYS.RIGHT: False,
                        KEYS.A: False, KEYS.B: False, KEYS.X: False, KEYS.Y: False, 
                        KEYS.L: False, KEYS.ZL: False, KEYS.R: False, KEYS.ZR: False,
                        KEYS.MINUS: False, KEYS.PLUS: False, KEYS.HOME: False}

        self.joystick_cursor_thread = None
        self.cursor_stop = threading.Event()
        self.cursor_queue = queue.Queue()



    def get_cursor(self) -> tuple[str, int]:
        size = int(get_output(["gsettings", "get", "org.gnome.desktop.interface", "cursor-size"]))
        name = get_output(["gsettings", "get", "org.gnome.desktop.interface", "cursor-theme"])

        return (name, size)

    def set_cursor(self, name: str, size: int):
        for cmd in [["gsettings", "set", "org.gnome.desktop.interface", "cursor-size", str(size)],
                    ["gsettings", "set", "org.gnome.desktop.interface", "cursor-theme", name],
                    ["hyprctl", "setcursor", name, str(size)]

                ]:
            subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    def set_mode(self, mode: Modes) -> None:
        self.mode = mode
        update_eww([("controller_menu", mode.value)])

    def game_mode(self, on: bool) -> None:
        if on:
            set_window("gamemode_desktop_popup", "close")

    def handle_game(self, evtype: EVENTS, event: int, value: int) -> None:
        if event == KEYS.PLUS and self.pressed[KEYS.HOME] and value == 1:
                self.set_mode(Modes.DESKTOP)
        elif event == KEYS.MINUS:
            if self.pressed[KEYS.HOME] and value == 1:
                set_window("performance_popup", "open")
            elif value == 0:
                set_window("performance_popup", "close")
        if self.pressed[KEYS.HOME] and self.pressed[KEYS.R] and self.pressed[KEYS.L]:
            os.system(f"{CONFIGS}/eww/shell/bin/screenshot_menu.sh screen disk current noeww")


    def desktop_mode(self, on: bool) -> None:
        if on:
            self.saved_cursor = self.get_cursor()
            self.set_cursor("bigpicture", 48)
            set_window("gamemode_desktop_popup", "open")
            self.controller._save_leds()
            self.controller.set_all(True)
            self.cursor_stop.clear()
            self.joystick_cursor_thread = threading.Thread(target=self.cursor_move, args=(self.cursor_queue,))
            self.joystick_cursor_thread.start()
        else:
            self.set_cursor(self.saved_cursor[0], self.saved_cursor[1])
            self.cursor_stop.set()
            self.joystick_cursor_thread.join()
            self.controller._restore_leds()

    def handle_desktop(self, evtype: EVENTS, event: int, value: int) -> None:
        if evtype == EVENTS.JS:
            self.cursor_queue.put(((self.joysticks[JOYSTICK.LEFT_HORIZONTAL],self.joysticks[JOYSTICK.LEFT_VERTICAL])
                                   ,(self.joysticks[JOYSTICK.RIGHT_HORIZONTAL],self.joysticks[JOYSTICK.RIGHT_VERTICAL])))
        elif evtype == EVENTS.BTN:
            if event == KEYS.A:
                set_click(0x00, value)
            elif event == KEYS.Y:
                set_click(0x01, value)
            elif event == KEYS.JS_LEFT:
                set_click(0x02, value)
            elif event == KEYS.LEFT and value == 1:
                self.socket.dispatch('workspace', args="m-1")
            elif event == KEYS.RIGHT and value == 1:
                self.socket.dispatch('workspace', args="m+1")
            elif event == KEYS.B and value == 1:
                self.set_mode(Modes.GAME)
            elif event == KEYS.PLUS and self.pressed[KEYS.HOME] and value == 1:
                self.set_mode(Modes.GAME)
            elif event == KEYS.ZR:
                set_press(125, value)
            





    def start_listening(self):
        self.jstest = subprocess.Popen(["jstest", "--event", self.controller.devfs], stdout=subprocess.PIPE)

        while True:
            line = self.jstest.stdout.readline().decode()
            if not line.startswith("Event"):
                continue
            fields = line.strip().split(',')
            type  = int(fields[0].split(" ")[2])
            id    = int(fields[2].split(" ")[2])
            value = int(fields[3].split(" ")[2])

            if type == EVENTS.BTN:
                self.pressed[id] = bool(value)
            elif type == EVENTS.JS:
                self.joysticks[id] = float(value)
            

            if self.mode != self.oldmode:
                self.mode_changes[self.oldmode.value](False)
                self.mode_changes[self.mode.value](True)
                self.oldmode = self.mode 
            else:
                self.mode_handles[self.mode.value](type, id, value)
    
    def cursor_move(self, value_queue):
        i = 0
        values = ((0,0),(0,0))
        while not self.cursor_stop.is_set():
            while not value_queue.empty():
                values = value_queue.get()
            if values[0] != (0,0):
                move_mouse(values[0][0], values[0][1])
            # poll this way more rarely
            if values[1] != (0,0) and i > 10:
                move_wheel(values[1][0], values[1][1])
                i = 0
            i+=1
            time.sleep(0.01)



def cleanup_on_exit(signum, frame, cons: list[Controller], listener: ControllerMonitor) -> None:
    for con in cons:
        con._restore_leds()
    update_eww([("controller_mode", "false"), ("controller_name", "")])
    listener.set_cursor(listener.saved_cursor[0], listener.saved_cursor[1])
    set_window("gamemode_desktop_popup", "close")
    os.remove(LOCKFILE)
    os._exit(0)
   




        

if __name__ == "__main__":
    with open (LOCKFILE, "w") as file:
        file.write(str(os.getpid()))
    devices = query_devices()
    device = devices[0]
    update_eww([("controller_name", device.name), ("controller_menu", "game"), ("controller_mode", "true")])
    ctl_socket = hypr.HyprctlSocket(hypr.HYPRCTL_SOCKET)
    listener = ControllerMonitor(device, ctl_socket)
    interrupt_handler = lambda signum, frame: cleanup_on_exit(signum, frame, devices, listener)
    signal.signal(signal.SIGINT, interrupt_handler)
    listener.start_listening()