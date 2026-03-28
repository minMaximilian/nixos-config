import QtQuick

import qs
import qs.services

Row {
    spacing: 2

    readonly property real brightness: Monitor.brightnessPercent()

    Text {
        text: {
            if (brightness < 0.25)
                return " 󰃞 ";
            if (brightness < 0.5)
                return " 󰃝 ";
            if (brightness < 0.75)
                return " 󰃟 ";
            return " 󰃠 ";
        }
        color: Config.barBacklightColor
        font.family: Config.fontFamily
        font.pixelSize: Config.barFontSize
        font.bold: true
        verticalAlignment: Text.AlignVCenter
    }

    Text {
        text: Math.round(brightness * 100) + "% "
        color: Config.barTextColor
        font.family: Config.fontFamily
        font.pixelSize: Config.barFontSize
        font.bold: true
        verticalAlignment: Text.AlignVCenter
    }
}
