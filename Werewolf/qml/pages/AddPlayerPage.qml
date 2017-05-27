import VPlayApps 1.0
import QtQuick 2.0

import "../model"

/*!
    \qmltype AddPlayerPage
    \inherits PlayerPage
    \brief Lets user add players.

    This page gets expanded when the \c FloatingActionButton in \c WerewolfMainPage is pushed. Every field is initally
    empty until the user fills them. A new player is created when the "Create" button gets pressed.
 */
PlayerPage {
    id: addPlayerPage

    title: "Create"

    /*!
        \qmlmethod AddPlayerPage::open()

        Expands the \c AddPlayerPage, sets expanded to \c true.
     */
    function open() {
        expanded = true
    }

    /*!
        \qmlmethod AddPlayerPage::close()

        Collapses and resets the \c AddPlayerPage, sets expanded to \c false.
     */
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
