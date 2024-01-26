#!/usr/bin/env python

import subprocess
from eww import CONFIGS

def read_val(path: str) -> str:
    with open (path, "r") as f:
        return f.read()
def write_val(path: str, content: str) -> str:
    with open (path, "w") as f:
        return f.write(content)

def get_output(cmd: list[str]) -> str:
    proc = subprocess.run(cmd, stdout=subprocess.PIPE)
    return proc.stdout

def adjust_audio(up: str, value="3", target="DEFAULT_SINK") -> None:
    verb = "raise" if up else "lower"
    subprocess.Popen([f"{CONFIGS}/eww/shell/popups/bin/open_popup.sh", "out", "audio", verb, value, target], stdout=subprocess.DEVNULL)

