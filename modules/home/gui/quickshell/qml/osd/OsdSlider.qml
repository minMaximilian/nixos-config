pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

import qs

Scope {
    id: root
    required property bool active
    required property string icon
    required property var value
    required property var borderColor

    LazyLoader {
        active: root.active

        PanelWindow {
            anchors.bottom: true
            margins.bottom: screen.height / 5
            exclusiveZone: 0
            aboveWindows: WlrLayer.Overlay

            implicitWidth: Config.osdSliderWidth
            implicitHeight: Config.osdSliderHeight
            color: "transparent"

            mask: Region {}

            Rectangle {
                anchors.fill: parent
                radius: Config.osdSliderBorderRadius
                color: Config.osdSliderBackground
                border.color: root.borderColor
                border.width: Config.osdSliderBorderSize

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: Config.osdSliderMargin
                        rightMargin: Config.osdSliderMargin
                    }

                    Text {
                        text: root.icon
                        font.pixelSize: Config.osdSliderIconSize
                        font.family: Config.fontFamily
                        color: Config.osdSliderFilled
                    }

                    Rectangle {
                        Layout.fillWidth: true

                        implicitHeight: Config.osdSliderBarHeight
                        radius: Config.osdSliderBarHeight / 2
                        color: Config.osdSliderUnfilled

                        Rectangle {
                            anchors {
                                left: parent.left
                                top: parent.top
                                bottom: parent.bottom
                            }

                            implicitWidth: parent.width * root.value
                            radius: parent.radius
                            color: Config.osdSliderFilled

                            Behavior on implicitWidth {
                                SmoothedAnimation { velocity: 800 }
                            }
                        }
                    }
                }
            }
        }
    }
}
