import QtQuick

import qs
import qs.services

Row {
    property string icon: Audio.sinkMuted ? "󰖁" : Audio.volume < 0.3 ? "  " : Audio.volume < 0.7 ? "  " : "  "
    property int vol: Math.round((Audio.volume < 1.0 ? Audio.volume : 1.0) * 100)

    Text {
        text: icon
        color: Config.accentGreen
        font.pixelSize: Config.fontSize
        font.family: Config.fontFamily
        font.bold: true
    }
    Text {
        text: " " + vol + "% "
        color: Config.textColor
        font.pixelSize: Config.fontSize
        font.family: Config.fontFamily
        font.bold: true
    }
}
