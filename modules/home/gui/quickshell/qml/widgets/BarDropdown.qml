import QtQuick
import Quickshell
import Quickshell.Hyprland

import qs

Item {
    id: root
    required property Item anchorItem
    property alias content: contentContainer.children
    property bool active: false

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (!root.active) return;
            var name = event.name;
            if (name === "activewindow" || name === "workspace" || name === "focusedmon")
                root.active = false;
        }
    }

    PopupWindow {
        visible: root.active
        anchor {
            item: root.anchorItem
            margins.top: Config.barMargin
            rect { y: root.anchorItem.height }
        }
        implicitWidth: contentContainer.implicitWidth
        implicitHeight: contentContainer.implicitHeight
        color: "transparent"

        Rectangle {
            id: contentContainer
            radius: Config.barBorderRadius
            color: Config.notificationBackground
            border.color: Config.accentBlue
            border.width: Config.notificationBorderWidth
        }
    }
}
