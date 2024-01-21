#!/usr/bin/env python

import asyncio
import signal
import subprocess
import os
import time
import threading
import queue

LOCKFILE="/tmp/eww/state/gaming/overlay"


EVENT_JS  = 2
EVENT_BTN = 1

UP    = 13
DOWN  = 14
LEFT  = 15
RIGHT = 16

A = 1
B = 0
X = 2
Y = 3

L=4
ZL=6

R=5
ZR=7

MINUS = 8
PLUS  = 9
HOME  = 10

LEFT_HORIZONTAL=0
LEFT_VERTICAL=1

RIGHT_HORIZONTAL=2
RIGHT_VERTICAL=3

#left for  more precise movements
SPEED_DIVIDER=2000
MOUSE_DELAY=0.02

BUTTON_DOWN = 0x40
BUTTON_UP   = 0x80

MOD=HOME

def read_val(path: str) -> str:
    with open (path, "r") as f:
        return f.read()
def write_val(path: str, content: str) -> str:
    with open (path, "w") as f:
        return f.write(content)

class Led:
    def __init__(self, path):
        self.path = path
        self.max = int(read_val(os.path.join(path, "max_brightness")))
        self.file = os.path.join(path, "brightness")
        self.position = int(path[-1])
        
    @property
    def on(self) -> bool:
        if int(read_val(self.file)) < self.max:
            return False
        else:
            return True

    @on.setter
    def on(self, state: bool):
        if state:
            write_val(self.file, str(self.max))
        else:
            write_val(self.file, "0")

class Controller:
    def __init__(self, sysfs_path: str, devfs_path: str):
        self.devfs = devfs_path
        self.sysfs = sysfs_path
        self.leds = self._get_leds()
        self.ledcount = len(self.leds)
        self._blink_thread = None
        self._stop_blinking = threading.Event()
        self._save_leds()
        self.blinking = False

    def _save_leds(self):
        self._ledstate = [led.on for led in self.leds]

    def  _restore_leds(self):
        for i, state in enumerate(self._ledstate):
            self.leds[i].on = state


    def start_blinking(self, delay=0.5):
        if self.ledcount < 1:
            return

        if self._blink_thread is None or not self._blink_thread.is_alive():
            self._save_leds()
            self._stop_blinking.clear()
            self._blink_thread = threading.Thread(target=self._blink, args=(delay,))
            self._blink_thread.start()
            self.blinking = True

    def stop_blinking(self):
        if self.ledcount < 1:
            return

        if self._blink_thread is not None and self._blink_thread.is_alive():
            self._stop_blinking.set()
            self._blink_thread.join()
            self.blinking = False
            self._restore_leds()



    def _blink(self, delay):
        while not self._stop_blinking.is_set():
            for led in self.leds:
                led.on = True
            time.sleep(delay)
            for led in self.leds:
                led.on = False
            time.sleep(delay)

    def _get_leds(self) -> list[Led]:
        leds = []
        ledpath = os.path.join(self.sysfs, "device/leds/")
        for file in os.scandir(ledpath):
            if file.is_dir():
                leds.append(Led(os.path.join(ledpath,file)))
        return sorted(leds, key=lambda x: x.position)


def query_devices() -> list[Controller]:
    controllers = []
    for root, dirs, files in os.walk('/dev/input'):
        for file in files:
            if not file.startswith("js"):
                continue
            devfs_path = os.path.join(root, file)
            sysfs_path = f"/sys/class/input/{file}/device"
            controllers.append(Controller(sysfs_path, devfs_path))
    return controllers

def move_mouse(x: int, y: int) -> None:
   subprocess.Popen(["ydotool", "mousemove", "-x", str(x//SPEED_DIVIDER), "-y", str(y//SPEED_DIVIDER)], stdout=subprocess.DEVNULL) 

def set_click(btn: int, state: int):
    if bool(state):
        btn = btn + BUTTON_DOWN
    else:
        btn = btn + BUTTON_UP
    subprocess.Popen(["ydotool", "click", str(hex(btn))], stdout=subprocess.DEVNULL)

def clean_leds_on_exit(signum, frame, cons: list[Controller]) -> None:
    for con in cons:
        con._restore_leds()
    os._exit(0)


class ControllerMonitor:
    def __init__(self, dev: Controller):
        self.controller = dev

        self.joysticks = { LEFT_VERTICAL: 0, LEFT_HORIZONTAL: 0,
                   RIGHT_VERTICAL: 0, RIGHT_HORIZONTAL: 0}

        self.overlay_active = False
        self.pressed = { UP: False, DOWN: False, LEFT: False, RIGHT: False,
                        A: False, B: False, X: False, Y: False, 
                        MINUS: False, PLUS: False, HOME: False}

        self.joystick_cursor_thread = None
        self.cursor_stop = threading.Event()
        self.cursor_queue = queue.Queue()


    def toggle_overview(self):
        if self.overlay_active:
            self.cursor_stop.clear()
            self.joystick_cursor_thread = threading.Thread(target=self.cursor_move, args=(self.cursor_queue,))
            self.joystick_cursor_thread.start()
            self.controller.start_blinking()
        else:
            self.cursor_stop.set()
            self.joystick_cursor_thread.join()
            self.controller.stop_blinking()


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

            if type == EVENT_BTN:
                self.pressed[id] = bool(value)
            
            if self.pressed[PLUS] and self.pressed[MOD]:
                self.overlay_active = not self.overlay_active
                self.toggle_overview()
                continue
        
            if self.overlay_active:
                if type == EVENT_JS:
                    self.joysticks[id] = float(value)
                    self.cursor_queue.put((self.joysticks[LEFT_HORIZONTAL],self.joysticks[LEFT_VERTICAL]))
                elif type == EVENT_BTN:
                    if id == A or id == ZL:
                        set_click(0x00, value)
                    elif id == B or id == ZR:
                        set_click(0x01, value)
                    elif id == Y:
                        set_click(0x02, value)
                        



    
    def cursor_move(self, value_queue):
        values = (0,0)
        while not self.cursor_stop.is_set():
            while not value_queue.empty():
                values = value_queue.get()
            if values != (0,0):
                move_mouse(values[0], values[1])
            time.sleep(0.01)


   




        

if __name__ == "__main__":
    devices = query_devices()
    interrupt_handler = lambda signum, frame: clean_leds_on_exit(signum, frame, devices)
    signal.signal(signal.SIGINT, interrupt_handler)
    device = devices[0]
    listener = ControllerMonitor(device)
    listener.start_listening()
