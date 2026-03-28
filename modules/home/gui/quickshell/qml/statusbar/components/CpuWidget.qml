import QtQuick
import Quickshell.Io

import qs

Row {
    id: root
    property int usage: 0
    property var lastIdle: 0
    property var lastTotal: 0

    Text {
        text: "  "
        color: Config.accentOrange
        font.pixelSize: Config.fontSize
        font.family: Config.fontFamily
        font.bold: true
    }
    Text {
        text: " " + usage + "% "
        color: Config.textColor
        font.pixelSize: Config.fontSize
        font.family: Config.fontFamily
        font.bold: true
    }

    Process {
        id: cpuProc
        command: ["sh", "-c", "head -1 /proc/stat"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return;
                var p = data.trim().split(/\s+/);
                var idle = parseInt(p[4]) + parseInt(p[5]);
                var total = p.slice(1, 8).reduce((a, b) => a + parseInt(b), 0);
                if (root.lastTotal > 0) {
                    root.usage = Math.round(100 * (1 - (idle - root.lastIdle) / (total - root.lastTotal)));
                }
                root.lastTotal = total;
                root.lastIdle = idle;
            }
        }
        Component.onCompleted: running = true
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: cpuProc.running = true
    }
}
