#!/usr/bin/env python

import os
import threading
import time
from enum import Enum

from utils import read_val, write_val 


class KEYS:
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

    JS_LEFT = 11
    JS_RIGHT = 12

    MINUS = 8
    PLUS  = 9
    HOME  = 10

class JOYSTICK:
    LEFT_HORIZONTAL=0
    LEFT_VERTICAL=1

    RIGHT_HORIZONTAL=2
    RIGHT_VERTICAL=3

class EVENTS:
    JS  = 2
    BTN = 1



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
        self.name = read_val(os.path.join(sysfs_path, "name"))
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

    def set_all(self, value: bool) -> None:
        for led in self.leds:
            led.on = value

    def set_leds(self, values: list[tuple]) -> None:
        for index, value in values:
            led = self.leds[index]
            if led is not None:
                led.on = value



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
        try:
            for file in os.scandir(ledpath):
                if file.is_dir():
                        leds.append(Led(os.path.join(ledpath,file)))
        except: 
            return []
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

