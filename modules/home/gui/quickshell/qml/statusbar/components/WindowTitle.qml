import QtQuick
import Quickshell.Hyprland

import qs

BarPill {
    id: root
    property string title: {
        var t = Hyprland.activeToplevel?.title ?? "";
        return t.length > 50 ? t.substring(0, 50) + "…" : t;
    }
    visible: title !== ""
    implicitWidth: titleText.implicitWidth + (Config.barPadding + 4) * 2

    content: [
        Text {
            id: titleText
            anchors.centerIn: parent
            text: root.title
            color: Config.textColor
            font.pixelSize: Config.fontSize
            font.family: Config.fontFamily
            font.bold: true
        }
    ]
}
