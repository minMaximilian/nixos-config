pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris

import qs

Rectangle {
    id: root
    color: "transparent"
    implicitHeight: content.implicitHeight
    implicitWidth: Config.notificationWidth

    property int selectedPlayer: {
        var idx = Mpris.players.values.findIndex(p => p.playbackState === MprisPlaybackState.Playing);
        return idx !== -1 ? idx : 0;
    }
    property MprisPlayer player: Mpris.players.values[selectedPlayer] || null

    visible: Mpris.players.values.length > 0

    ColumnLayout {
        id: content
        width: parent.width
        spacing: 8

        // Album art
        Image {
            Layout.alignment: Qt.AlignHCenter
            source: (root.player?.trackArtUrl ?? "")
            sourceSize.height: root.width / 2.5
            fillMode: Image.PreserveAspectFit
            visible: source != ""

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (root.player?.canRaise ?? false) root.player.raise();
                }
            }
        }

        // Track info
        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: root.width
            text: (root.player?.trackTitle ?? "") || "No track"
            elide: Text.ElideRight
            font.family: Config.fontFamily
            font.pixelSize: Config.notificationTitleSize
            font.bold: true
            color: Config.textColor
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: root.width
            text: (root.player?.trackArtist ?? "") || ""
            elide: Text.ElideRight
            font.family: Config.fontFamily
            font.pixelSize: Config.notificationBodySize
            color: Config.notificationBodyColor
            visible: text !== ""
        }

        // Controls
        MediaControls {
            Layout.alignment: Qt.AlignHCenter
            player: root.player
        }

        // Progress bar
        FrameAnimation {
            running: (root.player?.playbackState ?? MprisPlaybackState.Stopped) === MprisPlaybackState.Playing
            onTriggered: root.player.positionChanged()
        }

        Rectangle {
            id: progressBar
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: root.width - 20
            implicitHeight: 4
            radius: 2
            color: Config.overlayColor

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: function(ev) {
                    if ((root.player?.canSeek ?? false) && (root.player?.positionSupported ?? false))
                        root.player.position = root.player.length * (ev.x / progressBar.width);
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                visible: width >= radius
                width: parent.width * Math.min((root.player?.position ?? 0) / (root.player?.length ?? 1), 1.0)
                radius: parent.radius
                color: ((root.player?.positionSupported ?? false) && (root.player?.lengthSupported ?? false)) ? Config.accentBlue : parent.color
            }
        }

        // Time
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: {
                var pos = (root.player?.positionSupported ?? false) ? formatTime(root.player?.position ?? 0) : "-";
                var len = (root.player?.lengthSupported ?? false) ? formatTime(root.player?.length ?? 0) : "-";
                return pos + " / " + len;
            }
            font.family: Config.fontFamily
            font.pixelSize: Config.notificationBodySize
            color: Config.overlayColor

            function formatTime(time) {
                if (time === 0) return "0:00";
                var seconds = Math.floor(time % 60);
                var minutes = Math.floor(time / 60) % 60;
                var hours = Math.floor(time / 3600);
                var pad = seconds.toString().padStart(2, "0");
                return hours > 0 ? hours + ":" + minutes.toString().padStart(2, "0") + ":" + pad : minutes + ":" + pad;
            }
        }

        // Player switcher (only if multiple players)
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.player?.identity ?? ""
            font.family: Config.fontFamily
            font.pixelSize: Config.notificationBodySize
            color: Config.overlayColor
            visible: Mpris.players.values.length > 1

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.selectedPlayer = (root.selectedPlayer + 1) % Mpris.players.values.length;
                }
            }
        }
    }
}
