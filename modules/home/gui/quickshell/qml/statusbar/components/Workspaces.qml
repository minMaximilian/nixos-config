pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

import qs

BarPill {
    id: root

    implicitWidth: workspaceRow.implicitWidth + (Config.barPadding + 4) * 2

    content: [
        RowLayout {
            id: workspaceRow
            anchors.centerIn: parent
            spacing: 8

            Repeater {
                model: ScriptModel {
                    values: [...Hyprland.workspaces.values]
                        .filter(ws => ws.id > 0)
                        .sort((a, b) => a.id - b.id)
                }

                Text {
                    id: dot
                    required property HyprlandWorkspace modelData
                    property bool isActive: Hyprland.focusedWorkspace?.id === modelData.id

                    text: isActive ? "●" : "●"
                    color: isActive ? Config.accentBlue : Config.textColor
                    font.pixelSize: isActive ? 12 : 8
                    font.family: Config.fontFamily
                    font.bold: true

                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                    Behavior on font.pixelSize {
                        NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Hyprland.dispatch("workspace " + dot.modelData.id)
                    }
                }
            }
        }
    ]
}
