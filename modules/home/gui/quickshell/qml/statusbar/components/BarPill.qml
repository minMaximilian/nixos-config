import QtQuick

import qs

Rectangle {
    id: root
    property alias content: contentItem.data
    property bool hovered: mouseArea.containsMouse

    color: hovered ? Config.barPillHover : Config.barPillBackground
    radius: Config.barBorderRadius
    implicitHeight: Config.barHeight

    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }

    Item {
        id: contentItem
        anchors.fill: parent
        anchors.leftMargin: Config.barPadding + 4
        anchors.rightMargin: Config.barPadding + 4
    }
}
