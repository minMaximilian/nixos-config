pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

import qs
import "components"

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            property var modelData
            screen: modelData
            color: "transparent"
            implicitHeight: Config.barHeight + Config.barMargin

            anchors {
                top: true
                left: true
                right: true
            }

            WindowTitle {
                width: implicitWidth
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: Config.barMargin
                z: 1
            }

            RowLayout {
                anchors.fill: parent
                anchors.topMargin: Config.barMargin
                anchors.leftMargin: Config.barMargin
                anchors.rightMargin: Config.barMargin
                spacing: Config.barSpacing

                // === LEFT ===
                Workspaces {}

                BarPill {
                    implicitWidth: trayWidget.implicitWidth + (Config.barPadding + 4) * 2
                    visible: trayWidget.children.length > 0

                    content: [
                        Item {
                            anchors.fill: parent
                            TrayWidget {
                                id: trayWidget
                                anchors.centerIn: parent
                            }
                        }
                    ]
                }

                SessionButtons {}

                // === CENTER spacer ===
                Item { Layout.fillWidth: true }

                // === RIGHT ===
                BarPill {
                    implicitWidth: rightRow.implicitWidth + (Config.barPadding + 4) * 2

                    content: [
                        RowLayout {
                            id: rightRow
                            anchors.centerIn: parent
                            spacing: 2

                            NetworkWidget {}
                            BluetoothWidget {}
                            BatteryWidget {}
                            VolumeWidget {}
                            TempWidget {}
                            MemoryWidget {}
                            CpuWidget {}
                            ClockWidget {}
                        }
                    ]
                }
            }
        }
    }
}
