pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland

import qs
import qs.services

LazyLoader {
    active: NotificationService.visible.length > 0

    PanelWindow {
        id: popupTray
        implicitWidth: Config.notificationWidth
        color: "transparent"
        focusable: false

        WlrLayershell.namespace: "quickshell:notificationPopups"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusiveZone: 0

        anchors.top: true
        anchors.right: true
        anchors.bottom: true
        margins.top: Config.notificationMargin
        margins.right: Config.notificationMargin
        margins.bottom: Config.notificationMargin

        Column {
            anchors.right: parent.right
            spacing: Config.notificationSpacing
            width: parent.width

            Repeater {
                model: ScriptModel {
                    values: [...NotificationService.visible].reverse()
                }

                delegate: NotificationPopup {}
            }
        }
    }
}
