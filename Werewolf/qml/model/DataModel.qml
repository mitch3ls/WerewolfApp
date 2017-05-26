pragma Singleton

import VPlayApps 1.0
 import VPlay 2.0
import QtQuick 2.0

import ".."
import "./"

Item {
    id: dataModel

    signal newListData(var data)

    function addPlayer(player) {
        if (!isValidPlayerModel(player))
            return
        //don't do anything if the object isn't a player object


        localStorage.addPlayer(player) //add player to the localStorage
        newListData(getListModel()) //notify subscribers
    }

    function removePlayer(playerId) {
        localStorage.removePlayer(playerId)
        newListData(getListModel())
    }

    //turns players' list into a list of objects that can be passed into a list
    function getListModel() {
        var players = localStorage.getPlayers()
        return players.map(playerToListItem)
    }

    //turns player object into object that can be passed into a list
    function playerToListItem(player) {
        return {
            text: player.name,
            detailText: player.role,
            playerId: player.playerId
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

    Storage {
        id: localStorage

        property var players: []    //this is where the players' data is stored

        Component.onCompleted: localStorage.setValue("players", []) //players wouldn't be recognised

        function addPlayer(newPlayer) {
            var players = getPlayers()                  //get the current players

            newPlayer.playerId = getNextPlayerId()

            players.push(newPlayer)                     //add the new player to the list
            localStorage.setValue("players", players)   //store the modified list
        }

        function removePlayer(playerId) {
            var players = getPlayers()                  //get the current players
            players = players.filter(function(p) {
                return p.playerId !== playerId          //keep players if their playerId isn't the one to be removed
            })
            localStorage.setValue("players", players)   //store the modified list
        }

        function getPlayers() {
            return localStorage.getValue("players")
        }

        function getNextPlayerId() {
            var players = getPlayers()
            var lastItem = players[players.length - 1]      //take the last element of the players list
            return lastItem ? (lastItem.playerId + 1) : 0   //return its id + 1 or 0 if there is no element in the list
        }
}
}
