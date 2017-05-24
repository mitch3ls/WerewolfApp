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

        newListData(getListModel())
    }

    function getListModel() {
        return players.map(playerToListModel)
    }

    function playerToListModel(player) {
        return {
            text: player.name,
            detailText: player.role
        }
    }
}
