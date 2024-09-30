#!/usr/bin/env python

import os
import subprocess
import json
import argparse
import sys
import shutil

def check_if_available(executable):
    if shutil.which(executable) is not None:
        return True
    else:
        sys.stderr.write(f"File {executable} could not be found in path or is not executable.")
        raise FileNotFoundError

class Swww:
    def __init__(self):
        check_if_available("swww")
        check_if_available("swww-daemon")
        self.is_unified = False
        try: 
            self.status = subprocess.check_output(["swww","query"])
            self.running = True
            self.parse_status()
        except:
            self.status = None
            self.running = False
    def parse_status(self):
        status = self.status.decode().split("\n")
        monitors = {}
        for line in status:
            if line != "":
                line = line.split(":")
                display = line[0]
                monitors[display] = {}
                monitors[display]["resolution"] = line[1].split(",")[0].strip().split("x")
                monitors[display]["scale"] = line[2].split(",")[0].strip()
                monitors[display]["path"] = line[-1].strip()
        main_path = monitors[list(monitors.keys())[0]]["path"]
        self.is_unified = all(monitor["path"] == main_path for monitor in monitors.values())
    def start(self):
        subprocess.run(["swww"])


swww = Swww()
print(swww.is_unified)
