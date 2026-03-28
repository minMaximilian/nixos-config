//@ pragma UseQApplication
//@ pragma IconTheme Papirus

import Quickshell

import qs.osd
import qs.notifications
import qs.session
import qs.statusbar
import qs.lockscreen

ShellRoot {
    Volume {}
    Brightness {}
    NotificationPopupManager {}
    NotificationCenter {}
    Session {}
    Lockscreen {}
    Bar {}
}
