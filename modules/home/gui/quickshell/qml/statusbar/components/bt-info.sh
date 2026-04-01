#!/usr/bin/env bash
# Outputs paired device info and discovered devices
# Format: P|MAC|Name|Connected|Icon|Battery|Trusted
#         ---
#         D|MAC|Name|Icon

for mac in $(bluetoothctl devices Paired 2>/dev/null | awk '{print $2}'); do
    info=$(bluetoothctl info "$mac" 2>/dev/null)
    name=$(echo "$info" | grep 'Alias:' | sed 's/.*Alias: //')
    conn=$(echo "$info" | grep 'Connected:' | awk '{print $2}')
    icon=$(echo "$info" | grep 'Icon:' | awk '{print $2}')
    bat=$(echo "$info" | grep 'Battery Percentage' | grep -oP '\d+' | head -1)
    trust=$(echo "$info" | grep 'Trusted:' | awk '{print $2}')
    echo "P|$mac|$name|$conn|$icon|$bat|$trust"
done

echo "---"

paired=$(bluetoothctl devices Paired 2>/dev/null | awk '{print $2}')
for mac in $(bluetoothctl devices 2>/dev/null | awk '{print $2}'); do
    echo "$paired" | grep -q "$mac" && continue
    info=$(bluetoothctl info "$mac" 2>/dev/null)
    name=$(echo "$info" | grep 'Alias:' | sed 's/.*Alias: //')
    icon=$(echo "$info" | grep 'Icon:' | awk '{print $2}')
    echo "D|$mac|$name|$icon"
done
