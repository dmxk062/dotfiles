#!/usr/bin/env python

import subprocess
import os


def read_val(path: str) -> str:
    with open (path, "r") as f:
        return f.read()
def write_val(path: str, content: str) -> str:
    with open (path, "w") as f:
        return f.write(content)

def get_output(cmd: list[str]) -> str:
    proc = subprocess.run(cmd, stdout=subprocess.PIPE)
    return proc.stdout
