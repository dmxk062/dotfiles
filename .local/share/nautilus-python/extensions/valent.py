import dbus
from enum import IntFlag
import xml.etree.ElementTree as ET

from gi.repository import Nautilus, GObject

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

class ValentDevice(object):
    name: str
    id  : str
    state: int

    actionIface: dbus.Interface
    propIface: dbus.Interface

    def __init__(self, bus: dbus.Bus, id: str):
        self.obj = bus.get_object(BUS_NAME, BUS_ROOT + "/Device/" + id)

        self.actionIface = dbus.Interface(self.obj, ACTIONS)
        self.propIface = dbus.Interface(self.obj, dbus_interface=dbus.PROPERTIES_IFACE)

        self.name = self.propIface.Get(BUS_NAME + ".Device", "Name")
        self.id = self.propIface.Get(BUS_NAME + ".Device", "Id")
        self.state = self.propIface.Get(BUS_NAME + ".Device", "State")

    def call_action(self, name: str, params: list, data: dict):
        return self.actionIface.Activate(name, params, data)

    def send_files(self, event, files: list[Nautilus.FileInfo]):
        files = [f.get_uri() for f in files]
        # print(files)
        self.call_action("share.uris", [files], {})

def get_devs(bus: dbus.Bus) -> list[ValentDevice]:
    nodes = []

    iface = dbus.Interface(bus.get_object(BUS_NAME, BUS_ROOT + "/Device"), INTROSPECT)
    xml = iface.Introspect()
    tree = ET.fromstring(xml)

    for node in tree.findall("node"):
        subpath = node.get("name")
        if subpath:
            nodes.append(ValentDevice(bus, subpath))

    return nodes

BUS = dbus.SessionBus()

class ValentMenu(GObject.GObject, Nautilus.MenuProvider):
    def get_background_items(self, pwd: Nautilus.FileInfo) -> list[Nautilus.MenuItem]:
        return []

    def get_file_items(self, files: list[Nautilus.FileInfo]) -> list[Nautilus.MenuItem]:
        devs = get_devs(BUS)
        devs = [dev for dev in devs if (dev.state & DeviceState.PAIRED) and (dev.state & DeviceState.CONNECTED)]
        if len(devs) == 0:
            return []

        menuitem = Nautilus.MenuItem(
                name="Valent::main",
                label="Send to Phone",
                )

        submenu = Nautilus.Menu()

        for dev in devs:
            submenu_item = Nautilus.MenuItem(
                    name="Valent::dev::" + dev.id,
                    label=dev.name
                    )
            submenu_item.connect("activate", dev.send_files, files)
            submenu.append_item(submenu_item)

        menuitem.set_submenu(submenu)



        return [menuitem]
