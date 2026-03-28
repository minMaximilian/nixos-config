import QtQuick
import Quickshell.Io

import qs

Row {
    id: root
    property string netIcon: "󰤨"
    property string netText: ""

    Text {
        text: " " + netIcon + " "
        color: Config.accentCyan
        font.pixelSize: Config.fontSize
        font.family: Config.fontFamily
        font.bold: true
    }
    Text {
        text: netText + " "
        color: Config.textColor
        font.pixelSize: Config.fontSize
        font.family: Config.fontFamily
        font.bold: true
    }

    Process {
        id: netProc
        command: ["sh", "-c", "nmcli -t -f TYPE,STATE,CONNECTION device 2>/dev/null | grep ':connected:' | head -1"]
        stdout: SplitParser {
            onRead: data => {
                if (!data || data.trim() === "") {
                    root.netIcon = "";
                    root.netText = "Disconnected";
                    return;
                }
                var parts = data.trim().split(":");
                var type = parts[0] || "";
                var name = parts[2] || "";
                if (type === "wifi") {
                    root.netIcon = "󰤨";
                    root.netText = name;
                } else if (type === "ethernet") {
                    root.netIcon = "";
                    root.netText = "Wired";
                } else {
                    root.netIcon = "󱘖";
                    root.netText = name;
                }
            }
        }
        Component.onCompleted: running = true
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: netProc.running = true
    }
}
