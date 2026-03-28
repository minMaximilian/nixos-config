import QtQuick
import Quickshell.Io

import qs

Row {
    id: root
    property string usedStr: "0.0"
    property string totalStr: "0.0"

    Text {
        text: "  "
        color: Config.accentPurple
        font.pixelSize: Config.fontSize
        font.family: Config.fontFamily
        font.bold: true
    }
    Text {
        text: " " + usedStr + "G/" + totalStr + "G "
        color: Config.textColor
        font.pixelSize: Config.fontSize
        font.family: Config.fontFamily
        font.bold: true
    }

    Process {
        id: memProc
        command: ["sh", "-c", "free -m | grep Mem"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return;
                var parts = data.trim().split(/\s+/);
                var total = parseInt(parts[1]) || 0;
                var used = parseInt(parts[2]) || 0;
                root.usedStr = (used / 1024).toFixed(1);
                root.totalStr = (total / 1024).toFixed(1);
            }
        }
        Component.onCompleted: running = true
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: memProc.running = true
    }
}
