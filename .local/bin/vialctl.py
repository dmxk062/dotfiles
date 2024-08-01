#!/usr/bin/env python

import hid
import argparse
import struct
import colorsys
import sys
import re

VIAL_SERIAL_MAGIC = "vial:f64c2b3c"


class VialCmd:
    SET_LIGHTING = 0x07
    GET_LIGHTING = 0x08


# only those i care about rn
ANIMATIONS = {
    "off": 0,
    "direct": 1,
    "solid": 2,
    "breath": 6,
    "spiral": 12,
    "cycle": 13,
    "cycle_lr": 14,
    "cycle_ud": 15,
    "jellybeans": 25,
    "heatmap": 29,
    "rain": 30,
    "keypress": 31,
    "splash": 34,
    "linear_splash": 38,
    "wave": 39,
    "wave2": 41,
    "colors": 43,
}


def is_rawhid(dev: hid.DeviceInfo):
    return not (dev["usage_page"] != 0xFF60 or dev["usage"] != 0x61)


def find_vial_devices() -> list[hid.DeviceInfo]:
    res: list[hid.DeviceInfo] = []
    for dev in hid.enumerate():
        if VIAL_SERIAL_MAGIC in dev["serial_number"] and is_rawhid(dev):
            res.append(dev)

    return res


class VialKbd:
    def __init__(self, dev: hid.DeviceInfo):
        self.desc = dev
        self.max_brightness = self.cur_speed = self.cur_mode = 0
        self.cur_hsv = (0, 0, 0)
        self.supported_anims = {0}
        self.get_color_info()

    def msg(self, data: bytes) -> bytes:
        if len(data) > 32:
            raise RuntimeError("Message length must be 32 bytes")

        data += b"\x00" * (32 - len(data))  # padd
        with hid.Device(path=self.desc["path"]) as dev:
            num_written = dev.write(b"\x00" + data)
            response = dev.read(32, timeout=500)

        return response

    def get_color_info(self):
        data = self.msg(struct.pack("BB", VialCmd.GET_LIGHTING, 0x40))[2:]

        rgb_version = data[0] | (data[1] << 8)
        assert rgb_version == 1

        self.max_brightness = data[2]
        self.supported_anims = {0}
        max_effect = 0
        while max_effect < 0xFFFF:
            data = self.msg(
                struct.pack("<BBH", VialCmd.GET_LIGHTING, 0x42, max_effect)
            )[2:]
            for x in range(0, len(data), 2):
                value = int.from_bytes(data[x : x + 2], byteorder="little")
                if value != 0xFFFF:
                    self.supported_anims.add(value)
                max_effect = max(max_effect, value)

        data = self.msg(struct.pack("BB", VialCmd.GET_LIGHTING, 0x41))[2:]
        self.cur_mode = int.from_bytes(data[0:2], byteorder="little")
        self.cur_speed = data[2]
        self.cur_hsv = (data[3], data[4], data[5])

    def set_color(self, r: int, g: int, b: int, a: float):
        r_scaled, g_scaled, b_scaled = r / 255.0, g / 255.0, b / 255.0
        h, s, v = colorsys.rgb_to_hsv(r_scaled, g_scaled, b_scaled)
        if a is not None:
            v *= a

        self.msg(
            struct.pack(
                "BBHBBBB",
                VialCmd.SET_LIGHTING,
                0x41,
                self.cur_mode,
                self.cur_speed,
                int(h * 255),
                int(s * 255),
                int(v * 255),
            )
        )

    def set_animation(self, anim: int, speed: int or None):
        if anim not in self.supported_anims:
            raise RuntimeError("Animation not supported by device")
        self.msg(
            struct.pack(
                "BBHBBBB",
                VialCmd.SET_LIGHTING,
                0x41,
                anim,
                speed or self.cur_speed,
                self.cur_hsv[0],
                self.cur_hsv[1],
                self.cur_hsv[2],
            )
        )


def parse_hex_color(hex: str) -> (int, int, int, float or None):
    str = hex.lstrip("#")

    r = int(str[0:2], 16)
    g = int(str[2:4], 16)
    b = int(str[4:6], 16)
    if len(str) > 6:
        a = int(hex[6:8], 16) / 255.0
    else:
        a = None

    return r, g, b, a


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-l", "--list", action="store_true")
    parser.add_argument("-c", "--color", metavar="COLOR")
    parser.add_argument("-a", "--animation", metavar="ANIMATION")
    parser.add_argument("-L", "--list-animations", action="store_true", dest="list_animations")
    args = parser.parse_args()

    if args.list:
        devs = find_vial_devices()
        for dev in devs:
            print(f"{dev["path"].decode()} {dev["product_string"]}")
        exit(0)
    elif args.list_animations:
        print(", ".join(ANIMATIONS.keys()))
        exit(0)

    devs = find_vial_devices()
    if len(devs) == 0:
        print("No devices found", file=sys.stderr)
        exit(1)
    if args.color:
        color = parse_hex_color(args.color)
        for dev in devs:
            kbd = VialKbd(dev)
            kbd.set_color(*color)
    if args.animation:
        split = args.animation.split("@")
        anim = split[0]
        speed = len(split) > 1 and split[1] or None
        if re.match(r"\d+", anim):
            animcode = int(anim)
        else:
            animcode = ANIMATIONS.get(anim, None)
            if not animcode:
                print("Animation does not exist: " + anim, file=sys.stderr)
                exit(1)
        if speed:
            speed = int(speed.rstrip("%"))
            speed = int((speed * 255) / 100)
        for dev in devs:
            kbd = VialKbd(dev)
            kbd.set_animation(animcode, speed or None)


if __name__ == "__main__":
    main()
