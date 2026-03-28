import QtQuick
import Quickshell

import qs
import qs.services

Item {
    id: root
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Row {
        id: row

        Text {
            text: "  "
            color: Config.accentPurple
            font.pixelSize: Config.fontSize
            font.family: Config.fontFamily
            font.bold: true
        }
        Text {
            text: " " + Qt.formatDateTime(clock.date, "ddd dd MMM HH:mm") + " "
            color: Config.textColor
            font.pixelSize: Config.fontSize
            font.family: Config.fontFamily
            font.bold: true
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: NotificationService.ncActive = !NotificationService.ncActive
    }
}
