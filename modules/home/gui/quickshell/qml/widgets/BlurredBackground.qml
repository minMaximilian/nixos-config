import QtQuick
import Quickshell
import Quickshell.Wayland
import Qt5Compat.GraphicalEffects

Rectangle {
    id: root
    anchors.fill: parent
    required property ShellScreen screen
    property int blurRadius: 32
    color: "transparent"

    function captureFrame() {
        screenCapture.captureFrame();
    }

    ScreencopyView {
        id: screenCapture
        anchors.fill: parent
        captureSource: root.screen
        visible: false
        onCaptureSourceChanged: function () {
            if (hasContent)
                screenCapture.captureFrame();
        }
    }

    FastBlur {
        anchors.fill: parent
        source: screenCapture
        radius: root.blurRadius
    }
}
