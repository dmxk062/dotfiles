#!/usr/bin/env python

import os
import subprocess
import json

CONFIGS=os.getenv("XDG_CONFIG_HOME")

def update_eww(vals: list[tuple[str, str]], eww="shell") -> None:
    vars = [f"{name}={value}" for name, value in vals]

    subprocess.Popen(["eww","-c",f"{CONFIGS}/eww/{eww}", "update"] + vars, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def get_eww(var: "str") -> dict or list[dict]:
    eww_var = subprocess.run(["eww","-c",f"{CONFIGS}/eww/shell", "get", var], stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
    val = eww_var.stdout
    return json.loads(val)


def set_window(name: str, state: str, eww="shell") -> None:
    subprocess.Popen(["eww","-c",f"{CONFIGS}/eww/{eww}", state, name, ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
