pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell

import qs
import qs.services

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
                    values: Compositor.workspaces
                }

                Text {
                    id: dot
                    required property var modelData
                    // Compare against live Compositor.focusedWorkspaceId
                    // (a reactive binding on Hyprland's own focus state)
                    // rather than the snapshotted modelData.isFocused, which
                    // can lag a step behind the actual focus change.
                    property bool isActive: Compositor.focusedWorkspaceId === modelData.id

                    text: "●"
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
                        onClicked: Compositor.focusWorkspace(dot.modelData.id)
                    }
                }
            }
        }
    ]
}
