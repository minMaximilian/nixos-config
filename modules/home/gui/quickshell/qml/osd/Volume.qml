import QtQuick
import Quickshell

import qs
import qs.services

OsdSlider {
    active: Audio.sinkChanged
    icon: Audio.sinkMuted ? "󰝟" : Audio.volume < 0.3 ? "󰕿" : Audio.volume < 0.7 ? "󰖀" : "󰕾"
    value: Audio.volume < 1.0 ? Audio.volume : 1.0
    borderColor: Config.osdVolumeBorder
}
