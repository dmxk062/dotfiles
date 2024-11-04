#!/usr/bin/env python3

import dbus
import json
import sys
import xml.etree.ElementTree as ET
from enum import IntFlag, Enum
import argparse
import colorama as C
import time

BUS_NAME = "ca.andyholmes.Valent"
BUS_ROOT = "/ca/andyholmes/Valent"

INTROSPECT = "org.freedesktop.DBus.Introspectable"

ACTIONS = "org.gtk.Actions"


class DeviceState(IntFlag):
    NONE = 0
    CONNECTED = 1 << 0
    PAIRED    = 1 << 1
    PAIR_INCOMING = 1 << 2
    PAIR_OUTGOING = 1 << 3

class DeviceType(Enum):
    COMPUTER = "computer"
    PHONE = "phone"

BATTERY_ICONS = [ 
    ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹", "󰂎" ],
    ["󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"]
]

def introspect_object(obj) -> str:
    iface = dbus.Interface(obj, INTROSPECT)
    return iface.Introspect()

def getprop(obj, interface: str, name: str):
    iface = dbus.Interface(obj, dbus_interface=dbus.PROPERTIES_IFACE)

    return iface.Get(interface, name)

class ValentDevice:
    obj:  dbus.proxies.ProxyObject
    name: str
    id:   str
    state: int
    type: DeviceType

    iface: dbus.Interface
    props: dbus.Interface

    def __init__(self, obj: dbus.proxies.ProxyObject):
        self.obj = obj

        self.props = dbus.Interface(obj, dbus_interface=dbus.PROPERTIES_IFACE)
        self.iface = dbus.Interface(obj, ACTIONS)

        self.name = self.props.Get(BUS_NAME + ".Device", "Name")
        self.id = self.props.Get(BUS_NAME + ".Device", "Id")
        self.state = int(self.props.Get(BUS_NAME + ".Device", "State"))

        self.type =  DeviceType.COMPUTER if self.props.Get(BUS_NAME + ".Device", "IconName").startswith("computer") else DeviceType.PHONE

    @classmethod
    def new_for_id(cls, bus: dbus.Bus, id: str):
        return cls(bus.get_object(BUS_NAME, BUS_ROOT + "/Device/" + id))

    def call_action(self, name: str, params: list, data: dict):
        return self.iface.Activate(name, params, data, dbus_interface=ACTIONS)

    def desc_action(self, name: str):
        return self.iface.Describe(name)

    def get_battery(self):
        return self.desc_action('battery.state')[2]

    def notify(self, title: str, body: str, app: str): 
        timestamp = str(int(time.time()))
        notif = dbus.Dictionary({
            "id": timestamp,
            "title": app,
            "body": body,
            "application": title,
            }, signature="sv")

        self.call_action("notification.send", [notif], {})





def list_children(bus: dbus.Bus, bus_name: str, root: str) -> list[str]:

    nodes = []
    obj = bus.get_object(bus_name, root)
    xml = introspect_object(obj)

    tree = ET.fromstring(xml)

    for node in tree.findall("node"):
        subpath = node.get('name')
        if subpath:
            nodes.append(subpath)

    return nodes


def iter_devices(bus: dbus.Bus, callback: callable(ValentDevice), filter: callable(ValentDevice)):
    for dev in list_children(bus, BUS_NAME, BUS_ROOT + "/Device"):
        val = ValentDevice.new_for_id(bus, dev)
        if filter(val):
            callback(val)


def dev_matches(dev: ValentDevice, name: str, id: str):
    if not name and not id:
        return True
    if dev.id == id or dev.name.lower().startswith(name.lower()):
        return True
    else:
        return False



def print_devices(bus: dbus.Bus):
    devs = [ValentDevice.new_for_id(bus, d) for d in list_children(bus, BUS_NAME, BUS_ROOT + "/Device")]


    max_name_len = 0
    for dev in devs:
        if max_name_len < len(dev.name):
            max_name_len = len(dev.name)

    for dev in devs:
        paired = (dev.state & DeviceState.PAIRED) and (dev.state & DeviceState.CONNECTED)
        if paired: 
            c = C.Fore.MAGENTA + C.Style.BRIGHT
        else:
            c = C.Fore.BLUE

        battery = dev.get_battery()
        percentage = int(battery[0]["percentage"])
        if battery[0]["is-present"]:
            if battery[0]["charging"]:
                baticon = BATTERY_ICONS[1][(percentage // 10) - 1]
            else:
                baticon = BATTERY_ICONS[0][(percentage // 10) - 1]

            if percentage > 70:
                batcolor = C.Fore.GREEN
            elif percentage > 30:
                batcolor = C.Fore.YELLOW
            else:
                batcolor = C.Fore.RED
        else:
            baticon = BATTERY_ICONS[0][-1]
            batcolor = C.Fore.RED

        if dev.type == DeviceType.COMPUTER:
            icon = "󰌢" if paired else "󰛧"
        else:
            icon = "" if paired else "󰞃"
        print(f"{c}{icon} {dev.name:<{max_name_len}}  {C.Style.NORMAL}{batcolor}{baticon}{percentage:>3}% {C.Fore.RESET}{dev.id}")


def dev_to_json(dev: ValentDevice) -> str:
    battery_data = dev.get_battery()
    batteries = []
    for bat in battery_data:
        time = bat["time-to-full"] if bat["charging"] else bat["time-to-empty"]
        hours, remainder = divmod(time, 3600)
        minutes, seconds = divmod(remainder, 60)
        batteries.append({
            "percentage": bat["percentage"],
            "charging": bool(bat["charging"]),
            "available": bool(bat["is-present"]),
            "time_left": time,
            "time_left_split": {"hours": hours, "minutes": minutes, "seconds": seconds},
            })
    return {
        "name": dev.name,
        "id":   dev.id,
        "type": dev.type.value,
        "state": {
            "int": dev.state,
            "paired":       bool(dev.state & DeviceState.PAIRED),
            "connected": bool(dev.state & DeviceState.CONNECTED),
        },
        "battery": batteries
    }

def list_json(bus: dbus.Bus, id=None, name=None):
    devs = [ValentDevice.new_for_id(bus, d) for d in list_children(bus, BUS_NAME, BUS_ROOT + "/Device")]

    if len(devs) == 0:
        if id or name:
            return "null"
        else:
            return "[]"

    if not id and not name:
        buffer = []
        for dev in devs:
            buffer.append(dev_to_json(dev))
        return json.dumps(buffer)
    else:
        for dev in devs:
            if dev_matches(dev, name, id):
                return json.dumps(dev_to_json(dev))
        return "null"


    

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("action", choices=[
        "ls", "sms", "msg", "notify", "json", "send", "url", "file"
    ])
    parser.add_argument("-d" ,"--device", metavar="dev", help="Specify id")
    parser.add_argument("-n" ,"--name", metavar="dev", help="Filter by name")
    parser.add_argument("arguments" , metavar="arguments", nargs="*", help="Data for the action")
    args = parser.parse_args()

    if args.action in ("msg", "send", "url", "file") and not args.arguments:
        parser.error("Specify text/uri(s) to send")

    if args.action == "notify" and len(args.arguments) < 3:
        parser.error("Notify requires: title body app")

    C.init()
    bus = dbus.SessionBus()

    filter = lambda d: dev_matches(d, args.name, args.device)

    match args.action:
        case "ls":
            print_devices(bus)
        case "sms":
            iter_devices(bus, lambda d: d.call_action("sms.messaging", [], {}), filter)
        case "msg":
            iter_devices(bus, lambda d: d.call_action("ping.message", [" ".join(args.arguments)], {}), filter)
        case "notify":
            iter_devices(bus, lambda d: d.notify(args.arguments[0], args.arguments[1], args.arguments[2]), filter)
        case "send":
            iter_devices(bus, lambda d: d.call_action("share.text", [" ".join(args.arguments)], {}), filter)
        case "url":
            iter_devices(bus, lambda d: d.call_action("share.open", [args.arguments[0]], {}), filter)
        case "file":
            import urllib.parse
            import os

            files = ["file://" + urllib.parse.quote(os.path.realpath(p), safe="/") for p in args.arguments if os.path.exists(p)]
            if files:
                iter_devices(bus, lambda d: d.call_action("share.uris", [files], {}), filter)
            else:
                exit(1)
        case "json":
            sys.stdout.write(list_json(bus, id=args.device, name=args.name))




if __name__ == "__main__":
    main()
