import QtQuick

import qs
import qs.services

Rectangle {
    id: root
    implicitWidth: Config.barHeight
    implicitHeight: Config.barHeight
    radius: Config.barBorderRadius
    color: mouseArea.containsMouse ? Config.barPillHover : Config.barPillBackground

    Behavior on color { ColorAnimation { duration: 150 } }

    Text {
        anchors.centerIn: parent
        text: ""
        color: Config.accentRed
        font.pixelSize: Config.fontSize
        font.family: Config.fontFamily
        font.bold: true
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: SessionService.active = !SessionService.active
    }
}
