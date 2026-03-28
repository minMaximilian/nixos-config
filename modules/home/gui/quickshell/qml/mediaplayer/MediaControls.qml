import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris

import qs
import qs.widgets

RowLayout {
    id: root
    required property MprisPlayer player
    Layout.alignment: Qt.AlignCenter
    spacing: 16

    ClickableIcon {
        iconString: "󰒮"
        iconColor: (root.player?.canGoPrevious ?? false) ? Config.textColor : Config.overlayColor
        fontSize: 20
        clickAction: function() {
            if (root.player?.canGoPrevious) root.player.previous();
        }
    }

    ClickableIcon {
        iconString: (root.player?.isPlaying ?? false) ? "󰏤" : "󰐊"
        iconColor: (root.player?.canTogglePlaying ?? false) ? Config.textColor : Config.overlayColor
        fontSize: 24
        clickAction: function() {
            if (root.player?.canTogglePlaying) root.player.togglePlaying();
        }
    }

    ClickableIcon {
        iconString: "󰒭"
        iconColor: (root.player?.canGoNext ?? false) ? Config.textColor : Config.overlayColor
        fontSize: 20
        clickAction: function() {
            if (root.player?.canGoNext) root.player.next();
        }
    }
}
