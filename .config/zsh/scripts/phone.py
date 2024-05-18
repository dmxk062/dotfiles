#!/usr/bin/env python3

import dbus
import xml.etree.ElementTree as ET
from enum import IntFlag
import argparse

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
        self.iface.Activate(name, params, data, dbus_interface=ACTIONS)




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

    



def list_devices(): 
    bus = dbus.SessionBus()
    for dev in list_children(bus, BUS_NAME, BUS_ROOT + "/Device"):
        val = ValentDevice.new_for_id(bus, dev)
        print(f"{val.name} {val.id}")

def open_sms(device=None):
    bus = dbus.SessionBus()
    for dev in list_children(bus, BUS_NAME, BUS_ROOT + "/Device"):
        val = ValentDevice.new_for_id(bus, dev)
        if (not device or device == dev):
            val.call_action("sms.messaging", [], {})

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("action", metavar="action", choices=["ls", "sms"], default="ls", nargs="?")
    parser.add_argument("device", metavar="dev", nargs="?", help="Select the device to use, by default the first device is used")
    args = parser.parse_args()

    match args.action:
        case "ls":
            list_devices()
        case "sms":
            open_sms(args.device)


if __name__ == "__main__":
    main()
