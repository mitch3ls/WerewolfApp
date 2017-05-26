pragma Singleton

import VPlayApps 1.0
import VPlay 2.0
import QtQuick 2.0

import ".."
import "./"

Item {
    id: dataModel

    signal availabilityUpdated(var state)

    property alias roles: roleList
    property alias playersModel: listModel

    Component.onCompleted: {
        var players = getPlayers()
        listModel.setPlayers(players)
        roleList.shareAvailability()
    }

    function addPlayer(player) {
        if (!isValidPlayerModel(player))
            return
        //don't do anything if the object isn't a player object

        player.playerId = getNextPlayerId() //give new player an id

        listModel.addPlayer(player)
        localStorage.addPlayer(player) //add player to the localStorage
    }

    function removePlayer(playerId) {
        listModel.removePlayer(playerId)
        localStorage.removePlayer(playerId)
    }

    function modifyPlayer(player) {
        listModel.modifyPlayer(player)
        localStorage.modifyPlayer(player)
    }

    function getPlayerById(playerId) {
        var players = getPlayers()
        return players.filter(function(player) {
            return player.playerId === playerId
        })[0]
    }

    function getPlayersByRole(role) {
        var players = getPlayers()
        return players.filter(function(player) {
            return player.role === role
        })
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

    function getPlayers() {
        return localStorage.getValue("players")
    }

    function getHighestId() {
        var players = getPlayers()                  //get players
        var ids = players.map(function(player) {    //get their ids
                    return player.playerId
                })
        return Math.max.apply(Math, ids);           //return the highest id
    }

    function getNextPlayerId() {
        var players = getPlayers()
        var highestId = getHighestId()
        for (var i = 0; i <= highestId + 1; i++) {  //iterate from zero to the highest id + 1 (so that if there's no gap highestId + 1 will be used)
            var player = getPlayerById(i)           //get corresponding player
            if (!player) {                          //if the player not defined (the id is unassigned)
                return i                            //return the id
            }
        }
        return 0
    }

    ListModel {
        id: listModel

        function addPlayer(newPlayer) {
            var ownRoleIndex = roleList.getIndexForRole(newPlayer.role) //get own role index
            for (var i = 0; i < count; i++) {                           //iterate through players
                var player = get(i)                                     //take each player
                var role = player.role                                  //then their role
                var roleIndex = roleList.getIndexForRole(role)          //and get their index as well

                if (roleIndex > ownRoleIndex) {                         //now compare the indexes, if the own index is bigger than the one at the current position
                    insert(i, newPlayer)                                //then the item at this position has to be after the one we want to add so we add the player
                    return                                              //at that position
                }
            }
            append(newPlayer)               //if no player with a higher role index is found append the player
            console.log("appended")         //that also happens when the list is empty of course
        }

        function removePlayer(playerId) {
            for (var i = 0; i < count; i++) {       //iterate through players
                var player = get(i)                 //get each player
                if (player.playerId === playerId)   //if the playerId matches the one we want to remove
                    remove(i)                       //remove the player at that position
            }
        }

        function modifyPlayer(modifiedPlayer) {
            for (var i = 0; i < count; i++) {                       //iterate through players
                var player = get(i)                                 //get each player
                if (player.playerId === modifiedPlayer.playerId)    //if the playerId matches the one we want to remove
                    set(i, modifiedPlayer)                          //replace the player at that position
            }
        }

        function setPlayers(players) {                  //clears list
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

            handleNewPlayers(players)
        }

        function removePlayer(playerId) {
            var players = getPlayers()                  //get the current players

            players = players.filter(function(p) {return p.playerId !== playerId})       //keep players if their playerId isn't the one to be removed

            handleNewPlayers(players)
        }

        function modifyPlayer(player) {
            var players = getPlayers()                  //get the current list of players

            players = players.map(function(p) {         //replace every player in the list with,
                if (p.playerId === player.playerId)     //if the id matches the one given with the player,
                    return player                       //the new player
                else                                    //else
                    return p                            //with itself
            })

            handleNewPlayers(players)
        }

        function handleNewPlayers(players) {
            setValue("players", players)    //store the modified list
            roleList.shareAvailability()    //notify RoleChooser
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
            for (var i = 0; i < count; i++) {           //iterate through roles
                var entry = get(i)
                if (role === entry.name) return entry   //if the names match return the role object
            }
            return null
        }

        function isAvailable(role) {
            var playersWithRole = getPlayersByRole(role).length //get the number of players with the given role
            var maxCount = getRoleObject(role).maxPlayers       //get the highest possible numbers of players for that role

            if (maxCount)                                       //if there is an upper limit
                return maxCount > playersWithRole               //return whether there is room for more players
            return true                                         //always return true if there is no limit
        }

        function shareAvailability() {
            var state = {}

            for (var i = 0; i < count; i++) {           //iterate through roles
                var role = get(i)
                state[role.name] = {                    //create a property for each  role
                    available: isAvailable(role.name)   //with their availability
                }
            }

            availabilityUpdated(state)                         //publish the availability data
        }

        function compareRoles(role1, role2) {   //provide method for sorting by role
            return getIndexForRole(role1) - getIndexForRole(role2)
        }

        ListElement { name: "Werewolf"; pluralName: "Werewolves"; index: 0}
        ListElement { name: "Villager"; pluralName: "Villagers"; index: 3}
        ListElement { name: "Seer"; maxPlayers: 1; index:2}
        ListElement { name: "Witch"; maxPlayers: 1; index: 1}
    }
}
