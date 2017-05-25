pragma Singleton

import VPlayApps 1.0
import QtQuick 2.0

import ".."

Item {
    id: dataModel

    property var players

    signal newListData(var data)

    Component.onCompleted: {
        players = [{
                       name: "Hallo",
                       role: "Welt"
                   }, {
                       name: "foo",
                       role: "bar"
                   }]
    }

    function addPlayer(player) {
        players.push(player)

        console.log("player added")

        newListData(getListModel())
    }

    function getListModel() {   
        return players.map(playerToListModel)
    }

    function playerToListModel(player) {
        console.log(player.name, player.role)
        return {
            text: player.name,
            detailText: player.role
        }
    }
}
