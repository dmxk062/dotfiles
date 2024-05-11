#!/usr/bin/env python

import os
import socket
import json
import re

HYPRLAND_INSTANCE_SIGNATURE=os.getenv("HYPRLAND_INSTANCE_SIGNATURE")
RUNTIME_DIR=os.getenv("XDG_RUNTIME_DIR")
HYPRCTL_SOCKET=os.path.join(RUNTIME_DIR, "hypr",HYPRLAND_INSTANCE_SIGNATURE,".socket.sock")


class HyprctlSocket:
    def __init__(self, path):
        self.sockpath = path
    def connect(self):
        self.hyprsock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        self.hyprsock.connect(self.sockpath)
    def request(self, keywd, args=None):
        self.connect()
        request = f"j/{keywd}" if args is None else f"{keywd} {args}"
        try:
            self.hyprsock.sendall(request.encode())
        except: 
            pass
        return_value = self.hyprsock.recv(4096).decode()
        self.detach()
        return return_value
    def dispatch(self,keywd,args=None):
        self.connect()
        request = f"dispatch {keywd}" if args is None else f"dispatch {keywd} {args}"
        try:
            self.hyprsock.sendall(request.encode())
        except BrokenPipeError:
            pass
        self.detach()

    def detach(self):
        self.hyprsock.detach()
