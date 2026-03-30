import QtQuick
import Quickshell.Io

import qs

Row {
    id: root
    property string btIcon: "󰂲"
    property string btText: ""
    property bool btAvailable: false

    visible: root.btAvailable

    Text {
        text: " " + root.btIcon + " "
        color: Config.accentBlue
        font.pixelSize: Config.fontSize
        font.family: Config.fontFamily
        font.bold: true
    }
    Text {
        text: root.btText + " "
        color: Config.textColor
        font.pixelSize: Config.fontSize
        font.family: Config.fontFamily
        font.bold: true
        visible: root.btText !== ""
    }

    Process {
        id: btProc
        command: ["bash", "-c", "bluetoothctl show >/dev/null 2>&1 || { echo none; exit 0; }; bluetoothctl show 2>/dev/null | grep -q "Powered: yes" && { dev=$(bluetoothctl devices Connected 2>/dev/null | head -1 | cut -d" " -f3-); echo "on:$dev"; } || echo "off:""]
        stdout: StdioCollector {
            onStreamFinished: {
                var result = this.text.trim();
                if (result === "none" || result === "") {
                    root.btAvailable = false;
                    return;
                }
                root.btAvailable = true;
                var parts = result.split(":");
                var state = parts[0] || "off";
                var device = parts.slice(1).join(":").trim();
                if (state === "off") {
                    root.btIcon = "󰂲";
                    root.btText = "";
                } else if (device !== "") {
                    root.btIcon = "󰂱";
                    root.btText = device;
                } else {
                    root.btIcon = "󰂯";
                    root.btText = "";
                }
            }
        }
        Component.onCompleted: running = true
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: btProc.running = true
    }
}
