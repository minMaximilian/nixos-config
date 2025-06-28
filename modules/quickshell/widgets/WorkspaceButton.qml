import QtQuick
import "../config"

Rectangle {
    id: root
    
    property var workspace
    property bool hovered: mouseArea.containsMouse
    property bool hasWindows: workspace && workspace.windows && workspace.windows.length > 0
    
    width: 32
    height: 32
    radius: 6
    
    // Enhanced workspace styling
    color: {
        if (workspace && workspace.active) return Theme.activeBackground
        if (hovered) return Theme.subtle
        if (hasWindows) return Theme.widgetBackground
        return Theme.background
    }
    
    border.color: {
        if (workspace && workspace.active) return Theme.primary
        if (hasWindows) return Theme.borderColor
        return Theme.muted
    }
    border.width: workspace && workspace.active ? 2 : 1
    
    // Scale animation on hover
    scale: hovered ? 1.1 : 1.0
    Behavior on scale { 
        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
    }
    
    Text {
        anchors.centerIn: parent
        text: workspace ? workspace.id : "?"
        color: workspace && workspace.active ? Theme.activeText : Theme.foreground
        font.pointSize: 10
        font.bold: workspace && workspace.active
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        
        onClicked: {
            if (workspace) {
                console.log(`Switching to workspace ${workspace.id}`)
                workspace.activate()
            }
        }
    }
} 