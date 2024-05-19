#!/usr/bin/env python3

import dbus
import json
import sys
import xml.etree.ElementTree as ET
from enum import IntFlag
import argparse
import colorama as C

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

BATTERY_ICONS = [ "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹", "󰂎" ]

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

    iface: dbus.Interface

    def __init__(self, obj: dbus.proxies.ProxyObject):
        self.obj = obj
        self.name = getprop(obj, BUS_NAME + ".Device", "Name")
        self.id   = getprop(obj, BUS_NAME + ".Device", "Id")
        self.state= getprop(obj, BUS_NAME + ".Device", "State")

        self.iface = dbus.Interface(obj, ACTIONS)

    @classmethod
    def new_for_id(cls, bus: dbus.Bus, id: str):
        return cls(bus.get_object(BUS_NAME, BUS_ROOT + "/Device/" + id))

    def call_action(self, name: str, params: list, data: dict):
        return self.iface.Activate(name, params, data, dbus_interface=ACTIONS)

    def desc_action(self, name: str):
        return self.iface.Describe(name)

    def get_battery(self):
        return self.desc_action('battery.state')[2]





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


def iter_devices(bus: dbus.Bus, callback: callable(ValentDevice)):
    for dev in list_children(bus, BUS_NAME, BUS_ROOT + "/Device"):
        val = ValentDevice.new_for_id(bus, dev)
        callback(val)



def open_sms(device: ValentDevice, id=None):
    if ((not id or id == device.id) and device.state & DeviceState.PAIRED):
        device.call_action('sms.messaging', [], {})

def print_devices(bus: dbus.Bus):
    devs = []
    iter_devices(bus, lambda d: devs.append(d))

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
            baticon = BATTERY_ICONS[(percentage // 10) - 1]
            if percentage > 70:
                batcolor = C.Fore.GREEN
            elif percentage > 30:
                batcolor = C.Fore.YELLOW
            else:
                batcolor = C.Fore.RED
        else:
            baticon = BATTERY_ICONS[-1]
            batcolor = C.Fore.RED

        print(f"{c}{"" if paired else "󰤮"} {dev.name:<{max_name_len}}  {C.Style.NORMAL}{batcolor}{baticon}{percentage:>3}% {C.Fore.RESET}{dev.id}")

def send_msg(device: ValentDevice, message, id=None):
    if ((not id or id == device.id) and device.state & DeviceState.PAIRED):
        device.call_action("ping.message", [message], {})


def dev_to_json(dev: ValentDevice):
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
        "state": {
            "int": dev.state,
            "paired":       bool(dev.state & DeviceState.PAIRED),
            "connected": bool(dev.state & DeviceState.CONNECTED),
        },
        "battery": batteries
    }

def list_json(bus: dbus.Bus, id=None):
    devs = [ValentDevice.new_for_id(bus, d) for d in list_children(bus, BUS_NAME, BUS_ROOT + "/Device")]
    if len(devs) == 0:
        if id:
            return "null\n"
        else:
            return "[]\n"

    if not id:
        buffer = []
        for dev in devs:
            buffer.append(dev_to_json(dev))
        return json.dumps(buffer)
    else:
        for dev in devs:
            if dev.id == id:
                return json.dumps(dev_to_json(dev))


    

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("action", metavar="action", choices=["ls", "sms", "msg", "json"])
    parser.add_argument("-d" ,"--device", metavar="dev", help="Select the device to use")
    parser.add_argument("arguments" , metavar="arguments", nargs="*", help="Data for the action")
    args = parser.parse_args()

    if args.action == "msg" and not args.arguments:
        parser.error("Specify message to send")


    C.init()
    bus = dbus.SessionBus()
    match args.action:
        case "ls":
            print_devices(bus)
        case "sms":
            iter_devices(bus, lambda d: open_sms(d, id=args.device))
        case "msg":
            iter_devices(bus, lambda d: send_msg(d, " ".join(args.arguments), id=args.device))
        case "json":
            sys.stdout.write(list_json(bus, id=args.device))




if __name__ == "__main__":
    main()
