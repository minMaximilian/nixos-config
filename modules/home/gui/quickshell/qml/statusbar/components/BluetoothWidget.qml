import QtQuick
import Quickshell.Io

import qs

Row {
    id: root
    spacing: 2

    property string btStatus: "off"
    property string btDevice: ""

    Text {
        text: "  "
        color: Config.barBluetoothColor
        font.family: Config.fontFamily
        font.pixelSize: Config.barFontSize
        font.bold: true
        verticalAlignment: Text.AlignVCenter
    }

    Text {
        text: {
            if (root.btDevice !== "")
                return root.btDevice + " ";
            return root.btStatus + " ";
        }
        color: Config.barTextColor
        font.family: Config.fontFamily
        font.pixelSize: Config.barFontSize
        font.bold: true
        verticalAlignment: Text.AlignVCenter
    }

    Process {
        id: btProc
        running: true
        command: ["bash", "-c", "bluetoothctl show | grep -q 'Powered: yes' && (bluetoothctl devices Connected | head -1 | cut -d' ' -f3-) || echo 'off'"]
        stdout: StdioCollector {
            onStreamFinished: {
                var result = text.trim();
                if (result === "off" || result === "") {
                    root.btStatus = "off";
                    root.btDevice = "";
                } else if (result.length > 0) {
                    root.btStatus = "on";
                    root.btDevice = result;
                } else {
                    root.btStatus = "on";
                    root.btDevice = "";
                }
            }
        }
    }

    Timer {
        running: true
        repeat: true
        interval: 5000
        onTriggered: btProc.running = true
    }
}
