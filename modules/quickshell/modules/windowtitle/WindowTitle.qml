import QtQuick
import Quickshell.Hyprland

Column {
    width: 40
    height: 60
    spacing: 4

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        text: Hyprland.focusedWindow?.title || "Desktop"
        color: "#cdd6f4"  // Light gray text
        font.pointSize: 8
        wrapMode: Text.WordWrap
        maximumLineCount: 3
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
    }
} 