import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

import qs

Item {
    id: root
    property string btIcon: "󰂲"
    property string btText: ""
    property bool btAvailable: false
    property bool panelOpen: false
    property bool scanning: false
    property var pairedDevices: []
    property var discoveredDevices: []
    property string contextMac: ""
    property string contextName: ""
    property bool contextTrusted: false
    property bool contextConnected: false

    visible: root.btAvailable
    implicitWidth: btRow.implicitWidth
    implicitHeight: btRow.implicitHeight

    property string scriptsDir: Qt.resolvedUrl(".").toString().replace("file://", "")

    function deviceIcon(iconType) {
        if (!iconType) return "󰂯";
        if (iconType.indexOf("headset") >= 0 || iconType.indexOf("headphone") >= 0) return "󰋋";
        if (iconType.indexOf("keyboard") >= 0) return "󰌌";
        if (iconType.indexOf("mouse") >= 0) return "󰍽";
        if (iconType.indexOf("gaming") >= 0) return "󰊗";
        if (iconType.indexOf("phone") >= 0) return "󰏲";
        if (iconType.indexOf("computer") >= 0) return "󰌢";
        return "󰂯";
    }

    Row {
        id: btRow
        Text {
            id: iconText
            text: " " + root.btIcon + " "
            color: Config.accentBlue
            font.pixelSize: Config.fontSize
            font.family: Config.fontFamily
            font.bold: true
        }
        Text {
            text: root.btText + " "
            color: Config.textColor
            font.pixelSize: Config.fontSize
            font.family: Config.fontFamily
            font.bold: true
            visible: root.btText !== ""
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.panelOpen = !root.panelOpen;
            root.contextMac = "";
            if (root.panelOpen) scanInfoProc.running = true;
        }
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (!root.panelOpen) return;
            var name = event.name;
            if (name === "activewindow" || name === "workspace" || name === "focusedmon") {
                root.panelOpen = false;
                root.contextMac = "";
            }
        }
    }

    PopupWindow {
        id: popup
        visible: root.panelOpen
        anchor {
            item: iconText
            margins.top: Config.barMargin
            rect { y: iconText.height }
        }
        implicitWidth: 300
        implicitHeight: popupContent.implicitHeight + 2
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            radius: Config.barBorderRadius
            color: Config.notificationBackground
            border.color: Config.accentBlue
            border.width: Config.notificationBorderWidth

            ColumnLayout {
                id: popupContent
                width: parent.width
                spacing: 0

                RowLayout {
                    Layout.fillWidth: true
                    Layout.margins: 10
                    spacing: 8
                    Text {
                        text: "Bluetooth"
                        font.family: Config.fontFamily
                        font.pixelSize: Config.fontSize
                        font.bold: true
                        color: Config.textColor
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: "󱄤"
                        font.family: Config.fontFamily
                        font.pixelSize: Config.fontSize + 2
                        color: root.scanning ? Config.accentGreen : Config.overlayColor
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (!root.scanning) {
                                    root.scanning = true;
                                    scanOnProc.running = true;
                                    scanTimer.start();
                                }
                            }
                        }
                    }
                    Text {
                        text: root.btIcon === "󰂲" ? "Off" : "On"
                        font.family: Config.fontFamily
                        font.pixelSize: Config.fontSize
                        color: Config.overlayColor
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: toggleProc.running = true
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: Config.overlayColor }

                Repeater {
                    model: root.pairedDevices
                    delegate: Rectangle {
                        id: pairedItem
                        required property var modelData
                        Layout.fillWidth: true
                        implicitHeight: 40
                        color: pairedMouse.containsMouse ? Config.barPillHover : "transparent"
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 8
                            Text {
                                text: root.deviceIcon(pairedItem.modelData.icon)
                                font.family: Config.fontFamily
                                font.pixelSize: Config.fontSize + 2
                                color: pairedItem.modelData.connected ? Config.accentGreen : Config.overlayColor
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0
                                Text {
                                    text: pairedItem.modelData.name || pairedItem.modelData.mac
                                    font.family: Config.fontFamily
                                    font.pixelSize: Config.fontSize
                                    color: Config.textColor
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: {
                                        var parts = [];
                                        if (pairedItem.modelData.connected) parts.push("Connected");
                                        if (pairedItem.modelData.battery !== "") parts.push(pairedItem.modelData.battery + "%");
                                        if (pairedItem.modelData.trusted) parts.push("Trusted");
                                        return parts.join(" \u00b7 ");
                                    }
                                    font.family: Config.fontFamily
                                    font.pixelSize: Config.fontSize - 2
                                    color: Config.overlayColor
                                    visible: text !== ""
                                }
                            }
                        }
                        MouseArea {
                            id: pairedMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: function(mouse) {
                                if (mouse.button === Qt.RightButton) {
                                    root.contextMac = pairedItem.modelData.mac;
                                    root.contextName = pairedItem.modelData.name;
                                    root.contextTrusted = pairedItem.modelData.trusted;
                                    root.contextConnected = pairedItem.modelData.connected;
                                } else {
                                    root.contextMac = "";
                                    if (pairedItem.modelData.connected) {
                                        actionProc.command = ["bluetoothctl", "disconnect", pairedItem.modelData.mac];
                                    } else {
                                        actionProc.command = ["bluetoothctl", "connect", pairedItem.modelData.mac];
                                    }
                                    actionProc.running = true;
                                }
                            }
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    Layout.margins: 10
                    text: "No paired devices"
                    font.family: Config.fontFamily
                    font.pixelSize: Config.fontSize
                    color: Config.overlayColor
                    horizontalAlignment: Text.AlignHCenter
                    visible: root.pairedDevices.length === 0
                }

                Rectangle {
                    Layout.fillWidth: true; height: 1; color: Config.overlayColor
                    visible: root.discoveredDevices.length > 0
                }
                Text {
                    Layout.fillWidth: true
                    Layout.leftMargin: 10; Layout.topMargin: 6; Layout.bottomMargin: 2
                    text: "Nearby Devices"
                    font.family: Config.fontFamily
                    font.pixelSize: Config.fontSize - 2
                    font.bold: true
                    color: Config.overlayColor
                    visible: root.discoveredDevices.length > 0
                }
                Repeater {
                    model: root.discoveredDevices
                    delegate: Rectangle {
                        id: discItem
                        required property var modelData
                        Layout.fillWidth: true
                        implicitHeight: 36
                        color: discMouse.containsMouse ? Config.barPillHover : "transparent"
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10; anchors.rightMargin: 10
                            spacing: 8
                            Text {
                                text: root.deviceIcon(discItem.modelData.icon)
                                font.family: Config.fontFamily
                                font.pixelSize: Config.fontSize + 2
                                color: Config.overlayColor
                            }
                            Text {
                                text: discItem.modelData.name || discItem.modelData.mac
                                font.family: Config.fontFamily
                                font.pixelSize: Config.fontSize
                                color: Config.textColor
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            Text {
                                text: "󰒉"
                                font.family: Config.fontFamily
                                font.pixelSize: Config.fontSize
                                color: Config.accentBlue
                            }
                        }
                        MouseArea {
                            id: discMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                pairProc.command = ["bash", "-c", "bluetoothctl pair " + discItem.modelData.mac + " && bluetoothctl trust " + discItem.modelData.mac + " && bluetoothctl connect " + discItem.modelData.mac];
                                pairProc.running = true;
                            }
                        }
                    }
                }

                // Context menu
                Rectangle {
                    Layout.fillWidth: true
                    visible: root.contextMac !== ""
                    implicitHeight: contextCol.implicitHeight
                    color: Config.barPillBackground
                    ColumnLayout {
                        id: contextCol
                        width: parent.width
                        spacing: 0
                        Rectangle { Layout.fillWidth: true; height: 1; color: Config.overlayColor }
                        Text {
                            Layout.fillWidth: true; Layout.margins: 8
                            text: root.contextName
                            font.family: Config.fontFamily; font.pixelSize: Config.fontSize; font.bold: true
                            color: Config.textColor; elide: Text.ElideRight
                        }
                        Rectangle {
                            Layout.fillWidth: true; implicitHeight: 32
                            color: trustMouse.containsMouse ? Config.barPillHover : "transparent"
                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 10; spacing: 8
                                Text { text: root.contextTrusted ? "󰕥" : "󰕤"; font.family: Config.fontFamily; font.pixelSize: Config.fontSize; color: Config.accentBlue }
                                Text { text: root.contextTrusted ? "Untrust" : "Trust"; font.family: Config.fontFamily; font.pixelSize: Config.fontSize; color: Config.textColor }
                            }
                            MouseArea {
                                id: trustMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    actionProc.command = ["bluetoothctl", root.contextTrusted ? "untrust" : "trust", root.contextMac];
                                    actionProc.running = true; root.contextMac = "";
                                }
                            }
                        }
                        Rectangle {
                            Layout.fillWidth: true; implicitHeight: 32
                            color: removeMouse.containsMouse ? Config.barPillHover : "transparent"
                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 10; spacing: 8
                                Text { text: "󰆴"; font.family: Config.fontFamily; font.pixelSize: Config.fontSize; color: Config.accentRed }
                                Text { text: "Forget Device"; font.family: Config.fontFamily; font.pixelSize: Config.fontSize; color: Config.textColor }
                            }
                            MouseArea {
                                id: removeMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    actionProc.command = ["bash", "-c", "bluetoothctl disconnect " + root.contextMac + " 2>/dev/null; bluetoothctl remove " + root.contextMac];
                                    actionProc.running = true; root.contextMac = "";
                                }
                            }
                        }
                        Rectangle {
                            Layout.fillWidth: true; implicitHeight: 32
                            color: closeMouse.containsMouse ? Config.barPillHover : "transparent"
                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 10; spacing: 8
                                Text { text: "󰅖"; font.family: Config.fontFamily; font.pixelSize: Config.fontSize; color: Config.overlayColor }
                                Text { text: "Cancel"; font.family: Config.fontFamily; font.pixelSize: Config.fontSize; color: Config.textColor }
                            }
                            MouseArea {
                                id: closeMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: root.contextMac = ""
                            }
                        }
                    }
                }
            }
        }
    }

    Process {
        id: btProc
        command: ["bash", root.scriptsDir + "bt-status.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                var result = this.text.trim();
                if (result === "none" || result === "") { root.btAvailable = false; return; }
                root.btAvailable = true;
                var parts = result.split(":");
                var state = parts[0] || "off";
                var device = parts.slice(1).join(":").trim();
                if (state === "off") { root.btIcon = "󰂲"; root.btText = ""; }
                else if (device !== "") { root.btIcon = "󰂱"; root.btText = device; }
                else { root.btIcon = "󰂯"; root.btText = ""; }
            }
        }
        Component.onCompleted: running = true
    }

    Timer { interval: 5000; running: true; repeat: true; onTriggered: { btProc.running = true; if (root.panelOpen) scanInfoProc.running = true; } }

    Process {
        id: scanInfoProc
        command: ["bash", root.scriptsDir + "bt-info.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                var text = this.text.trim();
                var sections = text.split("---");
                var pairedLines = (sections[0] || "").trim().split("\n").filter(function(l) { return l.startsWith("P|"); });
                var discLines = (sections[1] || "").trim().split("\n").filter(function(l) { return l.startsWith("D|"); });
                var paired = [];
                for (var i = 0; i < pairedLines.length; i++) {
                    var p = pairedLines[i].split("|");
                    paired.push({ mac: p[1]||"", name: p[2]||"", connected: p[3]==="yes", icon: p[4]||"", battery: p[5]||"", trusted: p[6]==="yes" });
                }
                root.pairedDevices = paired;
                var disc = [];
                for (var j = 0; j < discLines.length; j++) {
                    var d = discLines[j].split("|");
                    var dname = d[2] || "";
                    if (dname === "" || dname === d[1]) continue;
                    disc.push({ mac: d[1]||"", name: dname, icon: d[3]||"" });
                }
                root.discoveredDevices = disc;
            }
        }
    }

    Process { id: scanOnProc; command: ["bluetoothctl", "--timeout", "10", "scan", "on"] }
    Timer { id: scanTimer; interval: 12000; onTriggered: { root.scanning = false; scanInfoProc.running = true; } }

    Process {
        id: toggleProc
        command: ["bash", "-c", "bluetoothctl show 2>/dev/null | grep -q 'Powered: yes' && bluetoothctl power off || bluetoothctl power on"]
        stdout: StdioCollector { onStreamFinished: { btProc.running = true; scanInfoProc.running = true; } }
    }

    Process { id: actionProc; stdout: StdioCollector { onStreamFinished: { btProc.running = true; scanInfoProc.running = true; } } }
    Process { id: pairProc; stdout: StdioCollector { onStreamFinished: { btProc.running = true; scanInfoProc.running = true; } } }
}
