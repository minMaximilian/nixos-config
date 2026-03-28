pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Qt5Compat.GraphicalEffects

import qs
import qs.services
import qs.widgets

LazyLoader {
    active: SessionService.active

    Variants {
        model: Quickshell.screens

        delegate: PanelWindow {
            id: session
            property var modelData
            property bool ready: false
            screen: modelData
            color: "transparent"

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.namespace: "quickshell:session"
            WlrLayershell.layer: WlrLayer.Overlay

            ScreencopyView {
                id: screenCapture
                anchors.fill: parent
                captureSource: session.screen
                visible: false

                Component.onCompleted: delayCapture.start()
            }

            Timer {
                id: delayCapture
                interval: 16
                onTriggered: {
                    screenCapture.captureFrame();
                    showTimer.start();
                }
            }

            Timer {
                id: showTimer
                interval: 32
                onTriggered: session.ready = true
            }

            FastBlur {
                anchors.fill: parent
                source: screenCapture
                radius: 48
                visible: session.ready
            }

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0, 0, 0, 0.3)
                visible: session.ready
            }

            MouseArea {
                anchors.fill: parent
                onClicked: SessionService.active = false
                z: 0
                visible: session.ready
            }

            RowLayout {
                anchors.centerIn: parent
                z: 1
                spacing: 24
                visible: session.ready

                Repeater {
                    model: [
                        { icon: "󰌾", label: "Lock", cmd: "qs ipc call lockscreen lock" },
                        { icon: "󰑓", label: "Reboot", cmd: "systemctl reboot" },
                        { icon: "󰐥", label: "Shutdown", cmd: "systemctl poweroff" }
                    ]

                    delegate: Rectangle {
                        id: btn
                        required property var modelData
                        width: 120
                        height: 120
                        radius: Config.barBorderRadius
                        color: btnMouse.containsMouse ? Config.barPillHover : Config.barPillBackground
                        border.color: btnMouse.containsMouse ? Config.accentBlue : "transparent"
                        border.width: Config.notificationBorderWidth

                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: btn.modelData.icon
                                font.family: Config.fontFamily
                                font.pixelSize: 32
                                color: Config.textColor
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: btn.modelData.label
                                font.family: Config.fontFamily
                                font.pixelSize: Config.fontSize
                                color: Config.textColor
                            }
                        }

                        MouseArea {
                            id: btnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Quickshell.execDetached(["sh", "-c", btn.modelData.cmd]);
                                SessionService.active = false;
                            }
                        }
                    }
                }
            }
        }
    }
}
