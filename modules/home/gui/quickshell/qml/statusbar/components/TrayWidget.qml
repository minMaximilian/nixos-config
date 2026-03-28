pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

import qs

RowLayout {
    spacing: 8

    Repeater {
        model: SystemTray.items.values

        Item {
            id: trayEntry
            required property SystemTrayItem modelData
            Layout.preferredWidth: Config.fontSize + 2
            Layout.preferredHeight: Config.barHeight - Config.barPadding * 2

            IconImage {
                anchors.centerIn: parent
                implicitSize: Config.fontSize
                source: trayEntry.modelData.icon
                smooth: true
                asynchronous: true
            }

            QsMenuAnchor {
                id: menuAnchor
                menu: trayEntry.modelData.menu

                anchor.window: trayEntry.QsWindow.window
                anchor.onAnchoring: {
                    const window = trayEntry.QsWindow.window;
                    const widgetRect = window.contentItem.mapFromItem(trayEntry, 0, trayEntry.height, trayEntry.width, trayEntry.height);
                    menuAnchor.anchor.rect = widgetRect;
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onClicked: mouse => {
                    if (trayEntry.modelData.onlyMenu || mouse.button === Qt.RightButton)
                        menuAnchor.open();
                    else if (mouse.button === Qt.LeftButton)
                        trayEntry.modelData.activate();
                    else
                        trayEntry.modelData.secondaryActivate();
                }
            }
        }
    }
}
