pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.Notifications
import Quickshell.Widgets
import Quickshell

import qs
import qs.services

Rectangle {
    id: root

    required property NotificationService.Notif modelData

    Component.onCompleted: {
        root.modelData.dismiss = () => {
            root.dismissNotif();
        };

        root.modelData.hideNotif = () => {
            root.hideNotif();
        };

        appearAnimation.running = true;
        root.modelData.startTimer();
    }

    // initially offscreen
    x: width
    opacity: 0

    width: Config.notificationWidth
    color: Config.notificationBackground
    radius: Config.notificationBorderRadius
    border.color: {
        switch (modelData.urgency || NotificationUrgency.Low) {
        case NotificationUrgency.Critical:
            return Config.notificationBorderUrgent;
        case NotificationUrgency.Normal:
            return Config.notificationBorderNormal;
        case NotificationUrgency.Low:
            return Config.notificationBorderLow;
        }
    }
    border.width: Config.notificationBorderWidth

    height: contentRow.height + Config.notificationPadding * 2

    // Slide-in animation
    ParallelAnimation {
        id: appearAnimation
        running: false

        NumberAnimation {
            target: root
            to: 0
            property: "x"
            duration: 200
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            target: root
            to: 1
            property: "opacity"
            duration: 200
        }
    }

    // Slide-out animation
    ParallelAnimation {
        id: discardAnimation
        running: false
        property var doAfter: () => {}

        NumberAnimation {
            target: root
            to: root.width
            property: "x"
            duration: 200
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            target: root
            to: 0
            property: "opacity"
            duration: 200
        }
        onFinished: () => {
            doAfter();
        }
    }

    function dismissNotif() {
        discardAnimation.doAfter = () => {
            root.modelData.notification.dismiss();
        };
        discardAnimation.running = true;
    }

    function hideNotif() {
        discardAnimation.doAfter = () => {
            root.modelData.visible = false;
        };
        discardAnimation.running = true;
    }

    // Close button
    Text {
        anchors {
            top: parent.top
            right: parent.right
            topMargin: Config.notificationPadding / 2
            rightMargin: Config.notificationPadding / 2
        }
        text: ""
        font.family: Config.fontFamily
        font.pixelSize: Config.notificationBodySize
        color: Config.notificationTitleColor

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.dismissNotif()
        }
    }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: Config.notificationPadding
        width: parent.width - Config.notificationPadding * 2

        // App icon or fallback
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            implicitHeight: Config.notificationIconSize
            implicitWidth: Config.notificationIconSize
            color: "transparent"

            Loader {
                id: appIcon
                active: root.modelData.hasAppIcon
                visible: appIcon.active
                asynchronous: true
                anchors.fill: parent

                IconImage {
                    anchors.fill: parent
                    smooth: true
                    implicitSize: Config.notificationIconSize
                    source: Quickshell.iconPath(root.modelData.appIcon)
                    asynchronous: true
                }
            }

            Loader {
                id: fallbackIcon
                active: !appIcon.active
                visible: fallbackIcon.active
                asynchronous: true
                anchors.fill: parent

                Text {
                    anchors.centerIn: parent
                    text: "󰂚"
                    font.family: Config.fontFamily
                    font.pixelSize: Config.notificationIconSize
                    color: Config.notificationTitleColor
                }
            }
        }

        // Text content
        Column {
            width: contentRow.width - Config.notificationIconSize - Config.notificationPadding
            spacing: 2

            Text {
                text: root.modelData.summary
                width: parent.width
                color: Config.notificationTitleColor
                font.family: Config.fontFamily
                font.pixelSize: Config.notificationTitleSize
                font.bold: true
                wrapMode: Text.Wrap
                elide: Text.ElideRight
                maximumLineCount: 1
                visible: text !== ""
            }

            Text {
                text: root.modelData.body
                width: parent.width
                color: Config.notificationBodyColor
                font.family: Config.fontFamily
                font.pixelSize: Config.notificationBodySize
                wrapMode: Text.Wrap
                elide: Text.ElideRight
                maximumLineCount: 3
                visible: text !== ""
            }
        }
    }
}
