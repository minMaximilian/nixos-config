pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

import Quickshell.Hyprland

import qs
import qs.services
import qs.widgets
import qs.mediaplayer

Scope {
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (!NotificationService.ncActive) return;
            var name = event.name;
            if (name === "activewindow" || name === "workspace" || name === "focusedmon")
                NotificationService.ncActive = false;
        }
    }

    LazyLoader {
    active: NotificationService.ncActive

    PanelWindow {
        id: ncWindow
        implicitWidth: Config.notificationWidth
        color: "transparent"
        focusable: true

        WlrLayershell.namespace: "quickshell:notificationCenter"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusiveZone: 0

        anchors.top: true
        anchors.right: true
        anchors.bottom: true
        margins.top: Config.notificationMargin
        margins.right: Config.notificationMargin
        margins.bottom: Config.notificationMargin

        Rectangle {
            anchors.fill: parent
            radius: Config.notificationBorderRadius
            color: Config.notificationBackground
            border.color: Config.notificationBorderNormal
            border.width: Config.notificationBorderWidth

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Config.notificationPadding
                spacing: Config.notificationSpacing

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Config.notificationSpacing

                    ClickableIcon {
                        iconString: NotificationService.doNotDisturb ? "󰪖" : "󰪕"
                        iconColor: NotificationService.doNotDisturb ? Config.accentRed : Config.accentBlue
                        fontSize: Config.notificationTitleSize + 4
                        clickAction: function() { NotificationService.doNotDisturb = !NotificationService.doNotDisturb; }
                    }

                    Text {
                        text: "Notifications"
                        font.family: Config.fontFamily
                        font.pixelSize: Config.notificationTitleSize
                        font.bold: true
                        color: Config.textColor
                    }

                    Item { Layout.fillWidth: true }

                    ClickableIcon {
                        iconString: "󰹺"
                        iconColor: Config.textColor
                        fontSize: Config.notificationTitleSize + 4
                        visible: NotificationService.hasNotifs
                        clickAction: function() { NotificationService.clearAll(); }
                    }

                    ClickableIcon {
                        iconString: "󰅖"
                        iconColor: Config.textColor
                        fontSize: Config.notificationTitleSize + 4
                        clickAction: function() { NotificationService.ncActive = false; }
                    }
                }

                // Notification list
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    Column {
                        width: parent.width
                        spacing: Config.notificationSpacing

                        Repeater {
                            model: ScriptModel {
                                values: [...NotificationService.list].reverse()
                            }

                            delegate: NotificationPopup {}
                        }
                    }
                }

                // Empty state
                Text {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: "No notifications"
                    font.family: Config.fontFamily
                    font.pixelSize: Config.fontSize
                    color: Config.overlayColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    visible: !NotificationService.hasNotifs
                }

                // Media player
                MediaPlayer {
                    Layout.fillWidth: true
                    Layout.topMargin: Config.notificationSpacing
                }
            }
        }
    }
    }
}
