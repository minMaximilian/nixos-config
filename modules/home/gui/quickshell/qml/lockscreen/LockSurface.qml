import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Fusion
import Qt5Compat.GraphicalEffects
import Quickshell

import qs

Rectangle {
    id: root
    required property LockContext context
    anchors.fill: parent
    color: Config.notificationBackground

    Image {
        id: wallpaper
        anchors.fill: parent
        source: Config.wallpaperPath
        fillMode: Image.PreserveAspectCrop
        visible: false
    }

    FastBlur {
        anchors.fill: wallpaper
        source: wallpaper
        radius: 48
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.3)
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 8

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: Qt.formatDateTime(clock.date, "HH:mm")
            color: Config.textColor
            font.family: Config.fontFamily
            font.pixelSize: 96
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: Qt.formatDateTime(clock.date, "dddd, MMMM d")
            color: Config.textColor
            font.family: Config.fontFamily
            font.pixelSize: 18
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 16
            text: root.context.pamMessage
            color: root.context.showFailure ? Config.accentRed : Config.textColor
            font.family: Config.fontFamily
            font.pixelSize: Config.fontSize
            visible: root.context.pamMessage !== ""
        }

        TextField {
            id: passwordBox
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 8
            implicitWidth: 280
            padding: 12
            focus: true
            enabled: !root.context.unlockInProgress
            echoMode: TextInput.Password
            inputMethodHints: Qt.ImhSensitiveData
            placeholderText: "Password"
            placeholderTextColor: Config.overlayColor
            passwordCharacter: '●'
            color: Config.textColor
            font.family: Config.fontFamily

            background: Rectangle {
                radius: Config.barBorderRadius
                color: Config.barPillBackground
                border.color: root.context.showFailure ? Config.accentRed : Config.accentBlue
                border.width: Config.notificationBorderWidth
            }

            onTextChanged: root.context.currentText = this.text
            onAccepted: root.context.tryUnlock()

            Connections {
                target: root.context

                function onCurrentTextChanged() {
                    passwordBox.text = root.context.currentText;
                }
            }
        }
    }

    Rectangle {
        id: powerBtn
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 24
        width: 48
        height: 48
        radius: Config.barBorderRadius
        color: powerMouse.containsMouse ? Config.barPillHover : Config.barPillBackground

        Text {
            anchors.centerIn: parent
            text: "󰐥"
            font.family: Config.fontFamily
            font.pixelSize: 22
            color: Config.textColor
        }

        MouseArea {
            id: powerMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Quickshell.execDetached(["sh", "-c", "systemctl poweroff"])
        }
    }
}
