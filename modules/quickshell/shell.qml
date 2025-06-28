import Quickshell
import Quickshell.Hyprland
import QtQuick

ShellRoot {
    PanelWindow {
        id: panel
        anchors {
            left: true
            top: true
            bottom: true
        }
        implicitWidth: 48
        exclusionMode: ExclusionMode.Exclusive

        Rectangle {
            anchors.fill: parent
            color: "#1e1e2e"  // Will be replaced by stylix
            border.color: "#313244"  // Will be replaced by stylix
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: 8

                // Workspaces section
                Column {
                    id: workspacesSection
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 4

                    Repeater {
                        model: Hyprland.workspaces
                        
                        Rectangle {
                            width: 32
                            height: 32
                            radius: 6
                            color: {
                                if (Hyprland.focusedWorkspace && modelData && Hyprland.focusedWorkspace.id === modelData.id) {
                                    return "#89b4fa";  // Will be replaced by stylix
                                } else if (modelData && modelData.windows && modelData.windows.length > 0) {
                                    return "#313244";  // Will be replaced by stylix
                                } else {
                                    return "#181825";  // Will be replaced by stylix
                                }
                            }
                            border.color: "#313244"  // Will be replaced by stylix
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: modelData ? modelData.id.toString() : ""
                                color: {
                                    if (Hyprland.focusedWorkspace && modelData && Hyprland.focusedWorkspace.id === modelData.id) {
                                        return "#1e1e2e";  // Will be replaced by stylix
                                    } else {
                                        return "#cdd6f4";  // Will be replaced by stylix
                                    }
                                }
                                font.pointSize: 10
                                font.bold: Hyprland.focusedWorkspace && modelData && Hyprland.focusedWorkspace.id === modelData.id
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (modelData) {
                                        Hyprland.dispatch("workspace " + modelData.id.toString());
                                    }
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

                // Window title section
                Column {
                    id: windowTitleSection
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 32
                    spacing: 4

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width
                        text: Hyprland.focusedWindow && Hyprland.focusedWindow.title ? Hyprland.focusedWindow.title : ""
                        color: "#cdd6f4"  // Will be replaced by stylix
                        font.pointSize: 8
                        wrapMode: Text.WordWrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                        visible: text.length > 0
                    }
                }

                // Spacer - pushes clock to bottom
                Item {
                    width: 1
                    height: Math.max(0, parent.height - workspacesSection.implicitHeight - windowTitleSection.implicitHeight - clockSection.implicitHeight - 32)
                }

                // Clock section - now at bottom with nerd font icon
                Column {
                    id: clockSection
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 4

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "󰅐"  // nf-md-clock-outline
                        color: "#cdd6f4"  // Will be replaced by stylix
                        font.family: "JetBrainsMono Nerd Font"
                        font.pointSize: 16
                    }

                    Text {
                        id: timeText
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Qt.formatTime(new Date(), "hh:mm")
                        color: "#cdd6f4"  // Will be replaced by stylix
                        font.family: "JetBrainsMono Nerd Font"
                        font.pointSize: 8
                        font.bold: true
                    }

                    Timer {
                        interval: 1000
                        running: true
                        repeat: true
                        onTriggered: timeText.text = Qt.formatTime(new Date(), "hh:mm")
                    }
                }
            }
        }
    }
} 