import VPlayApps 1.0
import QtQuick 2.0

import "../model"


/*!
    \qmltype ModifyPlayerPage
    \inherits PlayerPage
    \brief Lets user modify players.

    This page gets expanded when a item of \c playersList in \c WerewolfMainPage is pressed. Every field is initally
    filled with the player's current details. The player is modified when the "Modify Player" gets pressed.
 */
PlayerPage {
    id: modifyPlayerPage

    title: "Modify Player"

    /*!
        \qmlproperty var ModifyPlayerPage::player

        The player who's currently selected, null if no player is selected.
     */
    property var player: null


    /*!
        \qmlmethod ModifyPlayerPage::openWithPlayer(int playerId)

        Expands the \c ModifyPlayerPage and loads the player's details,
        sets expanded to true.
     */
    function openWithPlayer(playerId) {
        player = DataModel.getPlayerById(playerId)
        prepare()
        expanded = true
    }

    /*!
        \qmlmethod ModifyPlayerPage::close()

        Collapses the \c ModifyPlayerPage and resets it,
        sets expanded to false.
     */
    function close() {
        expanded = false
        player = null
        reset()
    }

    /*!
        \qmlmethod ModifyPlayerPage::prepare()

        Loads users data into the input fields.
     */
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
