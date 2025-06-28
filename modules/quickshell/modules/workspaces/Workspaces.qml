import QtQuick
import Quickshell.Hyprland

Column {
    spacing: 4

    Repeater {
        model: 12
        
        Rectangle {
            width: 32
            height: 32
            radius: 6
            color: {
                if (Hyprland.focusedWorkspace?.id === index + 1) {
                    return "#89b4fa";  // Blue - active workspace
                } else if (hasWindows) {
                    return "#313244";  // Dark gray - workspace with windows
                } else {
                    return "#181825";  // Darker gray - empty workspace
                }
            }
            border.color: "#313244"
            border.width: 1

            property bool hasWindows: {
                for (let workspace of Hyprland.workspaces) {
                    if (workspace.id === index + 1) {
                        return workspace.windows.length > 0;
                    }
                }
                return false;
            }

            Text {
                anchors.centerIn: parent
                text: (index + 1).toString()
                color: {
                    if (Hyprland.focusedWorkspace?.id === index + 1) {
                        return "#1e1e2e";  // Dark background for active text
                    } else {
                        return "#cdd6f4";  // Light text for inactive
                    }
                }
                font.pointSize: 10
                font.bold: Hyprland.focusedWorkspace?.id === index + 1
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    Hyprland.dispatch("workspace", (index + 1).toString());
                }
                onEntered: parent.scale = 1.1
                onExited: parent.scale = 1.0
            }

            Behavior on scale {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }
        }
    }
} 