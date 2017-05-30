pragma Singleton

import VPlayApps 1.0
import VPlay 2.0
import QtQuick 2.0

/*!
    \qmltype DataModel
    \inherits Item
    \brief Takes care of app's data.

    The \c DataModel is a Singleton object, that provides functions for adding, removing,
    modifying and finding players, as well as the \c ListModel of the players that is used
    by the \c AppListView in \c WerewolfMainPage.

    On startup it loads the players from the \c localStorage and populates the \c ListModel.
 */
Item {
    id: dataModel

    /*!
        \qmlsignal DataModel::availabilityUpdated(jsobject availabilityInformation)
        \brief Sends out information about roles' availability.

        In Werewolf certain roles should only be assigned to a single player per game
        (Like the Witch or the Seer). This signal takes care of that by letting the \c roleChooser
        in \c PlayerPage know which roles are available.

        Every time the player data is modified (when a player is added, removed or modified)
        it notifies its subscribers about the updated availabilities of the roles. It does that
        by sending an object like this:
        \code
            {
                "roleName": isAvailable("roleName"),
                ...
            }
        \endcode
     */
    signal availabilityUpdated(var availabilityInformation)


    /*!
        \qmlproperty alias DataModel::roles
        \inherits ListModel
        \brief Contains all possible roles.

        It contains a list of all possible roles including their properties and a set of functions
        that are all connected to roles.
     */
    property alias roles: roleList

    /*!
        \qmlproperty alias DataModel::playersListModel
        \inherits ListModel
        \brief Contains all players that are in the game.

        The playersListModel is, as the name suggests, a ListModel of the players that is used in the
        \c AppListView in the \c AppPlayerPage. This \c ListModel is directly referenced by the
        \c{AppListView}'s model property.
     */
    property alias playersListModel: listModel

    Component.onCompleted: {
        var players = localStorage.getPlayers()
        listModel.setPlayers(players)
        roleList.shareAvailability()
    }

    /*!
        \qmlmethod DataModel::addPlayer(jsobject player)

        Assigns \a player an ID and adds it to the \c playersListModel and the \c localStorage.

        Before it does that it checks whether the \a player is valid or not. If it's not a valid
        player object it simply stops (returns).
     */
    function addPlayer(player) {
        if (!isValidPlayerModel(player))
            return
        //don't do anything if the object isn't a player object

        player.playerId = getNextPlayerId() //give new player an id

        var roleObject = roleList.getRoleObject(player.role)

        listModel.addPlayer(player)
        localStorage.addPlayer(player) //add player to the localStorage
    }

    /*!
        \qmlmethod DataModel::removePlayer(int playerId)

        Removes player with the provided \a playerId from the \c playersListModel and the
        \c localStorage.
     */
    function removePlayer(playerId) {
        listModel.removePlayer(playerId)
        localStorage.removePlayer(playerId)
    }

    /*!
        \qmlmethod DataModel::modifyPlayer(jsobject player)

        Updates \a player in the \c playersListModel and the \c localStorage.
     */
    function modifyPlayer(player) {
        listModel.modifyPlayer(player)
        localStorage.modifyPlayer(player)
    }

    /*!
        \qmlmethod DataModel::getPlayerById(int playerId)

        Returns the player object with the given \c playerId or null if the \c playerId is not
        assigned to any player.
     */
    function getPlayerById(playerId) {
        var players = localStorage.getPlayers()
        for (var i = 0; i < players.length; i++) {
            var player = players[i]
            if (player.playerId === playerId)
                return player
        }
        return null
    }

    /*!
        \qmlmethod DataModel::getPlayersByRole(string role)

        Returns a list of players with the given \c role.
     */
    function getPlayersByRole(role) {
        var players = localStorage.getPlayers()
        return players.filter(function(player) {
            return player.role === role
        })
    }

    /*!
        \qmlmethod DataModel::isValidPlayerModel(jsobject player)

        Returns \c true if the name attribute isn't empty and the role attribute is a possible role.
     */
    function isValidPlayerModel(player) {
        return player.name !== "" && roleList.contains(player.role)
    } 

    /*!
        \qmlmethod DataModel::getHighestId()

        Returns the highest assigned id or \c -Infinity if there are no players in the game.
     */
    function getHighestId() {
        var players = localStorage.getPlayers()                  //get players
        var ids = players.map(function(player) {    //get their ids
                    return player.playerId
                })
        return Math.max.apply(Math, ids);           //return the highest id
    }

    /*!
        \qmlmethod DataModel::getNextPlayerId()

        Returns the next unassigned playerId.
     */
    function getNextPlayerId() {
        var players = localStorage.getPlayers()
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
        }                                   //that also happens when the list is empty of course

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
                if (player.playerId === modifiedPlayer.playerId) {  //if the playerId matches the one we want to remove
                    if (player.role === modifiedPlayer.role)        //and the role didn't change
                        set(i, modifiedPlayer)                      //replace the player at that position
                    else {                                          //if the roles did change
                        removePlayer(player.playerId)               //first remove the old player
                        addPlayer(modifiedPlayer)                    //and add the modified player back in
                    }
                }
            }
        }

        function setPlayers(players) {
            clear()                     //clears list
            players.forEach(addPlayer)  //adds every player in the players list
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

            players.sort(function(p1, p2) {             //sorts players by roles
                return roleList.compareRoles(p1.role, p2.role)
            })

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

        function getPlayers() {
            return getValue("players")
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

            for (var i = 0; i < count; i++) {               //iterate through roles
                var role = get(i)
                state[role.name] = isAvailable(role.name)   //create a property for each role with their availability
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
