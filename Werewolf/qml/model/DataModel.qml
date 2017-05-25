pragma Singleton

import VPlayApps 1.0
import QtQuick 2.0

import ".."
import "./"

Item {
    id: dataModel

    property var players: [] //this is where the players' data is stored

    signal newListData(var data)

    function addPlayer(player) {
        if (!isValidPlayerModel(player))
            return

        //don't do anything if the object isn't a player object
        players.push(player) //add player to list
        newListData(getListModel()) //notify subscribers
    }

    //turns players' list into a list of objects that can be passed into a list
    function getListModel() {
        return players.map(playerToListModel)
    }

    //turns player object into object that can be passed into a list
    function playerToListModel(player) {
        return {
            text: player.name,
            detailText: player.role
        }
    }

    //checks if player is valid player model
    function isValidPlayerModel(player) {
        return player.name !== "" && player.role !== ""
    }
    //I wanted to check whether the role exists in RoleList
    //but I kept getting weird reference errors, so I left
    //it like this, if anything goes wrong, there'd just be
    //a wrong role name being displayed in the list
}
