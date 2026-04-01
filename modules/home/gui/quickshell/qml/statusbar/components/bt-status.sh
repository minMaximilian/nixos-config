#!/usr/bin/env bash
# Outputs bluetooth status: none, off:, on:, or on:DeviceName
bluetoothctl show >/dev/null 2>&1 || { echo none; exit 0; }
if bluetoothctl show 2>/dev/null | grep -q 'Powered: yes'; then
    dev=$(bluetoothctl devices Connected 2>/dev/null | head -1 | cut -d' ' -f3-)
    echo "on:$dev"
else
    echo "off:"
fi
