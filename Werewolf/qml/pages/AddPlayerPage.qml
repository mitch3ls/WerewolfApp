import VPlayApps 1.0
import QtQuick 2.0

import "../model"

PlayerPage {
    id: addPlayerPage

    title: "Create"

    function open() {
        expanded = true
    }

    function close() {
        expanded = false
        reset()
    }

    onSubmit: {
        DataModel.addPlayer(player) //add player to the data model
        close()
    }

    opacity: expanded ? 1 : 0 //only opaque when expanded
    Behavior on opacity {
        //smooth transition from transparent to opaque
        NumberAnimation {
            easing.type: Easing.InOutSine
            duration: 200
        }
    }

    y: expanded ? 0 : 2 * height //lets player creation fly in and out
    Behavior on y {
        //again, smooth transitions
        NumberAnimation {
            easing.type: Easing.OutExpo
            duration: 200
        }
    }

    z: 1 //player creation menu hovers above list
}
