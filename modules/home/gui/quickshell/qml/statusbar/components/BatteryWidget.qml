import QtQuick
import Quickshell.Io

import qs

Row {
    id: root
    property int capacity: -1
    property string status: ""
    property bool hasBattery: capacity >= 0
    property string icon: status === "Charging" ? "󱐋" :
                          capacity < 15 ? "󰂎" :
                          capacity < 30 ? "󰁼" :
                          capacity < 60 ? "󰁿" :
                          capacity < 85 ? "󰂁" : "󰁹"

    visible: hasBattery

    Text {
        text: " " + icon + " "
        color: Config.accentGreen
        font.pixelSize: Config.fontSize
        font.family: Config.fontFamily
        font.bold: true
    }
    Text {
        text: capacity + "% "
        color: Config.textColor
        font.pixelSize: Config.fontSize
        font.family: Config.fontFamily
        font.bold: true
    }

    Process {
        id: batProc
        command: ["sh", "-c", "cat /sys/class/power_supply/BAT*/capacity /sys/class/power_supply/BAT*/status 2>/dev/null || echo '-1'"]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.trim().split("\n");
                if (lines.length >= 2) {
                    root.capacity = parseInt(lines[0]) || -1;
                    root.status = lines[1].trim() || "";
                } else {
                    root.capacity = -1;
                }
            }
        }
        Component.onCompleted: running = true
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: batProc.running = true
    }
}
