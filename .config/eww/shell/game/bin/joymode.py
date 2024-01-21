#!/usr/bin/env python

import evdev
import subprocess
import os

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

MINUS = 8
PLUS  = 9
HOME  = 10

LEFT_HORIZONTAL=0
LEFT_VERTICAL=1

RIGHT_HORIZONTAL=2
RIGHT_VERTICAL=3

#left for  more precise movements
SPEED_DIVIDER=3000


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

    def _get_leds(self) -> list[Led]:
        leds = []
        ledpath = os.path.join(self.sysfs, "device/leds/")
        for file in os.scandir(ledpath):
            if file.is_dir():
                leds.append(Led(os.path.join(ledpath,file)))
        return sorted(leds, key=lambda l: l.position)


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
   os.system(f"ydotool mousemove -x {x//SPEED_DIVIDER} -y {y//SPEED_DIVIDER}") 

def monitor(dev: str) -> None:
    jstest = subprocess.Popen(["jstest", "--event", dev], stdout=subprocess.PIPE)

    while True:
        line = jstest.stdout.readline().decode()
        if not line.startswith("Event"):
            continue
        fields = line.strip().split(',')
        type  = int(fields[0].split(" ")[2])
        id    = int(fields[2].split(" ")[2])
        value = int(fields[3].split(" ")[2])
        print(value)


