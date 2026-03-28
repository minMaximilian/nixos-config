import QtQuick
import Quickshell.Io

import qs

Row {
    id: root
    property int temp: 0

    Text {
        text: ""
        color: Config.accentOrange
        font.pixelSize: Config.fontSize
        font.family: Config.fontFamily
        font.bold: true
    }
    Text {
        text: "  " + temp + "°C "
        color: Config.textColor
        font.pixelSize: Config.fontSize
        font.family: Config.fontFamily
        font.bold: true
    }

    Process {
        id: tempProc
        command: ["sh", "-c", "for d in /sys/class/hwmon/hwmon*; do [ \"$(cat $d/name 2>/dev/null)\" = k10temp ] && awk '{printf \"%d\", $1/1000}' $d/temp1_input && exit; done; echo 0"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return;
                root.temp = parseInt(data.trim()) || 0;
            }
        }
        Component.onCompleted: running = true
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: tempProc.running = true
    }
}
