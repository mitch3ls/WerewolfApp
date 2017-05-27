import VPlayApps 1.0
import QtQuick 2.0

import "../model"

PlayerPage {
    id: modifyPlayerPage

    title: "Modify Player"

    property var player: null

    function openWithPlayer(playerId) {
        player = DataModel.getPlayerById(playerId)
        prepare()
        expanded = true
    }

    function close() {
        expanded = false
        player = null
        reset()
    }

    function prepare() {        //fill PlayerPage with players details
        name = player.name
        notes = player.notes
        role = player.role
        roleText = player.role  //a workaround because the property bindings were acting weird
    }

    onSubmit: {
        player.playerId = modifyPlayerPage.player.playerId
        DataModel.modifyPlayer(player) //add player to the data model
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

    z: 1 //player modification menu hovers above list
}
