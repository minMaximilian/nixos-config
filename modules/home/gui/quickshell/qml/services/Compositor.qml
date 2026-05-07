pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland

/*
 * Compositor — unified compositor IPC abstraction.
 *
 * Detects whether quickshell runs under Hyprland or Niri at startup, then
 * exposes a single API used by the rest of the shell:
 *
 *   property var  workspaces            — list of {id, name, isFocused, isActive, output}
 *   property int  focusedWorkspaceId    — id of focused workspace (-1 if unknown)
 *   property var  activeToplevel        — Quickshell.Wayland.Toplevel of focused window
 *   property string activeTitle         — title of focused window (convenience)
 *   signal focusChanged()               — emitted on focus/workspace change (used to auto-close popups)
 *   function focusWorkspace(id)         — switch to workspace by id
 *
 * Hyprland: thin wrapper around Quickshell.Hyprland.
 * Niri:     parses `niri msg --json event-stream` for state, uses `niri msg action …` to dispatch.
 *
 * Window title comes from Quickshell.Wayland.ToplevelManager which is a generic
 * wayland protocol both compositors implement.
 */
Singleton {
    id: root

    readonly property bool isHyprland: Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") !== ""
    readonly property bool isNiri: !root.isHyprland && Quickshell.env("NIRI_SOCKET") !== ""

    property var workspaces: []
    property int focusedWorkspaceId: -1

    readonly property var activeToplevel: ToplevelManager.activeToplevel
    readonly property string activeTitle: activeToplevel?.title ?? ""

    signal focusChanged

    function focusWorkspace(id) {
        if (root.isHyprland) {
            Hyprland.dispatch("workspace " + id);
        } else if (root.isNiri) {
            niriDispatch.command = ["niri", "msg", "action", "focus-workspace", String(id)];
            niriDispatch.running = true;
        }
    }

    /* ---------- Hyprland integration ---------- */

    function _refreshHyprland() {
        var ws = [...Hyprland.workspaces.values]
            .filter(w => w.id > 0)
            .sort((a, b) => a.id - b.id)
            .map(w => ({
                id: w.id,
                name: w.name,
                isFocused: Hyprland.focusedWorkspace?.id === w.id,
                isActive: w.active ?? false,
                output: w.monitor?.name ?? ""
            }));
        root.workspaces = ws;
        root.focusedWorkspaceId = Hyprland.focusedWorkspace?.id ?? -1;
    }

    Component.onCompleted: {
        if (root.isHyprland) root._refreshHyprland();
    }

    Connections {
        target: root.isHyprland ? Hyprland : null
        function onRawEvent(event) {
            var n = event.name;
            if (n === "workspace" || n === "createworkspace" || n === "destroyworkspace"
                || n === "focusedmon" || n === "activewindow") {
                root._refreshHyprland();
                root.focusChanged();
            }
        }
    }

    /* ---------- Niri integration ---------- */

    Process {
        id: niriEvents
        running: root.isNiri
        command: ["niri", "msg", "--json", "event-stream"]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: line => root._onNiriLine(line)
        }
    }

    Process {
        id: niriDispatch
    }

    function _onNiriLine(line) {
        var s = line.trim();
        if (s === "") return;
        var ev;
        try { ev = JSON.parse(s); } catch (e) { return; }
        if (ev.WorkspacesChanged) {
            root._setNiriWorkspaces(ev.WorkspacesChanged.workspaces);
            root.focusChanged();
        } else if (ev.WorkspaceActivated) {
            root._activateNiriWorkspace(ev.WorkspaceActivated.id, ev.WorkspaceActivated.focused);
            root.focusChanged();
        } else if (ev.WorkspaceActiveWindowChanged) {
            root.focusChanged();
        } else if (ev.WindowFocusChanged) {
            root.focusChanged();
        } else if (ev.WindowsChanged || ev.WindowOpenedOrChanged || ev.WindowClosed) {
            // window list mutations don't change workspace focus state on their own
        }
    }

    function _setNiriWorkspaces(list) {
        var focused = -1;
        var mapped = list.map(w => {
            if (w.is_focused) focused = w.id;
            return ({
                id: w.id,
                name: w.name ?? String(w.idx),
                isFocused: !!w.is_focused,
                isActive: !!w.is_active,
                output: w.output ?? ""
            });
        }).sort((a, b) => a.id - b.id);
        root.workspaces = mapped;
        root.focusedWorkspaceId = focused;
    }

    function _activateNiriWorkspace(id, focused) {
        var changed = false;
        var next = root.workspaces.map(w => {
            var copy = Object.assign({}, w);
            if (w.id === id) {
                copy.isActive = true;
                if (focused) copy.isFocused = true;
                changed = true;
            } else if (focused && w.output === (root.workspaces.find(x => x.id === id)?.output ?? "")) {
                // unfocus siblings on same output
                copy.isFocused = false;
            }
            return copy;
        });
        if (changed) {
            root.workspaces = next;
            if (focused) root.focusedWorkspaceId = id;
        }
    }
}
