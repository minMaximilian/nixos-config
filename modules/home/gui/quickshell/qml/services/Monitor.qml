pragma Singleton

import Quickshell
import QtQuick
import Quickshell.Io

Singleton {
    id: root
    property int maxBrightness: 1
    property int currentBrightness: 0
    property bool brightnessChanged: false

    function brightnessPercent(): real {
        return root.maxBrightness > 0 ? root.currentBrightness / root.maxBrightness : 0;
    }

    Process {
        id: getMax
        running: true
        command: ["brightnessctl", "max"]
        stdout: StdioCollector {
            onStreamFinished: root.maxBrightness = parseInt(text) || 1
        }
    }

    Process {
        id: getCurrent
        running: true
        command: ["brightnessctl", "get"]
        stdout: StdioCollector {
            onStreamFinished: {
                var val = parseInt(text) || 0;
                if (root.currentBrightness != val) {
                    root.currentBrightness = val;
                    root.brightnessChanged = true;
                    changeTimer.restart();
                }
            }
        }
    }

    Timer {
        id: changeTimer
        interval: 1500
        onTriggered: root.brightnessChanged = false
    }

    Timer {
        running: true
        repeat: true
        interval: 200
        onTriggered: getCurrent.running = true
    }
}
