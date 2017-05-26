import VPlayApps 1.0
import QtQuick 2.0
import QtGraphicalEffects 1.0

import "pages"
import "model"


/*!
    \qmltype WerewolfMainPage.html WerewolfMainPage
    \inherits Page
    \brief Contains all visual components of the app.

    The WerewolfMainPage contains ever visual element of the app and acts as the
    root page of the app. (Even though it technically isn't)
*/
Page {
    id: werewolfMainPage

    /*!
        \qmlproperty bool addPlayerPageExpanded
        \brief Describes whether \c addPlayerPage is expanded or not.

        It gets modified by the \c playerCreationControl and the \c addPlayerPage
        itself. (it closes itself when a player is successfully created)
    */
    property bool addPlayerPageExpanded: false

    /*!
        \qmltype DataModelConnection
        \inherits Connections
        \brief Connects the \c DataModel to the \c playersList's model property.

        Connects to the \c newListData signal of \c DataModel and recieves new players data.
        This data is then assigned to the \c playersList's model propert.
    */
    Connections {
        target: DataModel
        //onNewListData: playersList.model = data
    }

    /*!
        \qmltype PlayerCreationControl
        \inherits FloatingActionButton
        \brief Controlls \c addPlayerPageExpanded.

        The \c PlayerCreationControl is a \c FloatingActionButton that is used to expand and
        collapse the \c addPlayerPage.

        When the \c addPlayerPage is closed it also is resetted, so that the old values don't
        remain in the forms.

        The plus icon rotates by 45 degrees when the \c addPlayerPage is expanded and becomes
        a closing a icon.
    */
    FloatingActionButton {
        id: playerCreationControl

        icon: IconType.plus

        //rotates Icon by 45 degrees when player creation is expanded
        //so it becomes the closing icon
        iconItem.rotation: addPlayerPageExpanded ? 45 : 0
        Behavior on iconItem.rotation {
            NumberAnimation {
                duration: 200
            }
        }

        onClicked: {
            if (addPlayerPageExpanded) {
                //acts as closing button
                addPlayerPageExpanded = false //closes player creation and resets it
                addPlayerPage.reset()
            } else
                addPlayerPageExpanded = true //opens player creation
        }

        z: 2 //hovers over the entire layout
        visible: true //necessary if not running on Android
    }

    AddPlayerPage {
        id: addPlayerPage

        onPlayerCreated: {
            DataModel.addPlayer(player) //add player to the data model
            addPlayerPageExpanded = false //collapses player creation
            reset() //resets player creation
        }

        opacity: addPlayerPageExpanded ? 1 : 0 //only opaque when expanded
        Behavior on opacity {
            //smooth transition from transparent to opaque
            NumberAnimation {
                easing.type: Easing.InOutSine
                duration: 200
            }
        }

        y: addPlayerPageExpanded ? 0 : 2 * height //lets player creation fly in and out
        Behavior on y {
            //again, smooth transitions
            NumberAnimation {
                easing.type: Easing.OutExpo
                duration: 200
            }
        }

        z: 1 //player creation hovers above list
    } //AddPlayerPage

    AppListView {
        id: playersList

        emptyText.text: "No Players in Session" //gets displayed when there are no players in the list
         //fetches initial data

        model: DataModel.playersModel

        section.property: "role"
        section.delegate: SimpleSection {
            Component.onCompleted: {
                var role = title                                        //get role from title
                var roleObject = DataModel.roles.getRoleObject(role)    //get role as object
                title = roleObject.pluralName || role                   //assign pluralName to title if it exists, fall back to role if not
            }
        }

        delegate: SwipeOptionsContainer {

            height: listItem.height //use item's height
            SimpleRow {
                id: listItem

                text: name
                detailText: notes

                textItem.font.bold: true
                detailTextItem.color: Theme.tintColor
            }

            rightOption: SwipeButton {  //button that appears when the element is swiped to the left
                icon: IconType.trasho   //trashcan icon
                height: parent.height   //use parent's height
                onClicked: DataModel.removePlayer(playerId)   //remove player when clicked
            }
        } //SwipeOptionsContainer
    } //ListPage

    FastBlur {
        id: blur
        source: playersList
        anchors.fill: playersList

        radius: addPlayerPageExpanded ? 10 : 0 //blur list when player creation is expanded
        Behavior on radius {
            //and add a fancy smooth transition
            NumberAnimation {
                easing.type: Easing.OutExpo
                duration: 200
            }
        } //Behavior
    } //FastBlur
}
