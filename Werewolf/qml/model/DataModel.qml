pragma Singleton

import VPlayApps 1.0
import VPlay 2.0
import QtQuick 2.0

import ".."
import "./"

Item {
    id: dataModel

    signal newListData(var data)

    property alias roles: roleList
    property alias playersModel: listModel

    Component.onCompleted: {
        var players = localStorage.getPlayers()
        listModel.setPlayers(players)
        newListData(listModel)
    }

    function addPlayer(player) {
        if (!isValidPlayerModel(player))
            return
        //don't do anything if the object isn't a player object

        player.playerId = localStorage.getNextPlayerId() //give new player an id

        localStorage.addPlayer(player) //add player to the localStorage
        newListData(listModel) //notify subscribers
    }

    function removePlayer(playerId) {
        localStorage.removePlayer(playerId)
        newListData(listModel)
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
        return player.name !== "" && roleList.contains(player.role)
    }

    ListModel {
        id: listModel

        function addPlayer(player) {
            listModel.append(player)    //adds player to the list
        }

        function setPlayers(players) {
            clear()                     //clears list
            players.forEach(addPlayer)
        }
    }

    Storage {
        id: localStorage

        property var players: []    //this is where the players' data is stored

        Component.onCompleted: {
            if (!getPlayers()) setValue("players", [])  //if players is not defined, add it to the storage
        }

        function addPlayer(newPlayer) {
            var players = getPlayers()                  //get the current players
            players.push(newPlayer)                     //add the new player to the list

            players.sort(function(p1, p2) {return roleList.compareRoles(p1.role, p2.role)}) //sorts players by roles

            listModel.setPlayers(players)
            localStorage.setValue("players", players)   //store the modified list
        }

        function removePlayer(playerId) {
            var players = getPlayers()                  //get the current players

            players = players.filter(function(p) {return p.playerId !== playerId})       //keep players if their playerId isn't the one to be removed

            listModel.setPlayers(players)
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

    ListModel {
        id: roleList

        function contains(role) {
            for (var i = 0; i < count; i++) {           //iterate through possible roles
                if (role === get(i).name) return true   //return true when the role is found
            }
            return false                                //return false if the role is not found
        }

        function getIndexForRole(role) {
            return getRoleObject(role).index
        }

        function getRoleObject(role) {
            for (var i = 0; i < count; i++) {
                var entry = get(i)
                if (role === entry.name) return entry
            }
            return null
        }

        function compareRoles(role1, role2) {
            return getIndexForRole(role1) - getIndexForRole(role2)
        }

        ListElement { name: "Werewolf"; pluralName: "Werewolves"; index: 0}
        ListElement { name: "Villager"; pluralName: "Villagers"; index: 3}
        ListElement { name: "Seer"; index:2}
        ListElement { name: "Witch"; index: 1}
    }
}
