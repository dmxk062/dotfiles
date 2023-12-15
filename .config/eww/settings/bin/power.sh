#!/usr/bin/env bash

print_info() {
    read -ra devices <<< "$(upower --enumerate)"

}

