pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root
    property bool sinkChanged: false
    property bool sinkMuted: Pipewire.defaultAudioSink?.audio.muted ?? true
    property double volume: Pipewire.defaultAudioSink?.audio.volume ?? 0

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Timer {
        id: sinkTimer
        interval: 1500
        onTriggered: root.sinkChanged = false
    }

    Connections {
        target: Pipewire.defaultAudioSink?.audio ?? null

        function onVolumeChanged() {
            root.sinkChanged = true;
            sinkTimer.restart();
        }

        function onMutedChanged() {
            root.sinkChanged = true;
            sinkTimer.restart();
        }
    }
}
