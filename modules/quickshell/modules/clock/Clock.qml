import QtQuick

Column {
    spacing: 4

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: "🕐"
        font.pointSize: 16
    }

    Text {
        id: timeText
        anchors.horizontalCenter: parent.horizontalCenter
        text: Qt.formatTime(new Date(), "hh:mm")
        color: "#cdd6f4"  // Light gray text
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