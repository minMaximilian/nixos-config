import QtQuick
import Quickshell

import qs
import qs.services

OsdSlider {
    active: Monitor.brightnessChanged
    icon: Monitor.brightnessPercent() < 0.5 ? "󰃞" : "󰃠"
    value: Monitor.brightnessPercent()
    borderColor: Config.osdBrightnessBorder
}
