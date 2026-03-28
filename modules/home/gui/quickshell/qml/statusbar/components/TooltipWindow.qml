import QtQuick
import Quickshell

import qs

Scope {
    id: root
    required property Item anchorItem
    required property Item content
    required property bool visible
    property color borderColor: Config.accentBlue

    PopupWindow {
        id: previewWindow
        visible: root.visible

        anchor {
            item: root.anchorItem
            margins.top: Config.barMargin
            rect {
                y: root.anchorItem.height
            }
        }

        implicitWidth: contentContainer.width
        implicitHeight: contentContainer.height
        color: "transparent"

        Rectangle {
            implicitWidth: contentContainer.width
            implicitHeight: contentContainer.height
            border.color: root.borderColor
            color: Config.barPillBackground
            border.width: Config.notificationBorderWidth
            radius: Config.barBorderRadius
            opacity: previewWindow.visible ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }

            Item {
                id: contentContainer
                implicitWidth: root.content.implicitWidth
                implicitHeight: root.content.implicitHeight
                anchors.centerIn: parent
                children: [root.content]
            }
        }
    }
}
