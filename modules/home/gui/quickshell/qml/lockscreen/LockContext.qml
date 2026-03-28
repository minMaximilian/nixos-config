import Quickshell
import Quickshell.Services.Pam

Scope {
    id: root
    signal unlocked

    property string currentText: ""
    property bool unlockInProgress: false
    property bool showFailure: false
    property string pamMessage: ""

    onCurrentTextChanged: showFailure = false

    function tryUnlock() {
        if (currentText !== "") {
            root.unlockInProgress = true;
            pam.start();
        }
    }

    PamContext {
        id: pam

        config: "quickshell"

        onPamMessage: {
            if (this.responseRequired) {
                this.respond(root.currentText);
            }
            if (this.messageIsError) {
                root.pamMessage = this.message;
            }
        }

        onCompleted: result => {
            if (result == PamResult.Success) {
                root.pamMessage = "";
                root.currentText = "";
                root.unlocked();
            } else {
                root.currentText = "";
                root.showFailure = true;
            }

            root.unlockInProgress = false;
        }
    }
}
