import VPlayApps 1.0
import QtQuick 2.0
import QtGraphicalEffects 1.0

import "pages"
import "model"

Page {
    id: werewolfMainPage


    property bool playerCreationExpanded: false

    //updates list when new data is available
    Connections {
        target: DataModel
        onNewListData: playersList.model = data
    }

    FloatingActionButton {
        id: expandPlayerCreation

        icon: IconType.plus

        //rotates Icon by 45 degrees when player creation is expanded
        //so it becomes the closing icon
        iconItem.rotation: playerCreationExpanded ? 45 : 0
        Behavior on iconItem.rotation {
            NumberAnimation {
                duration: 200
            }
        }

        onClicked: {
            if (playerCreationExpanded) {       //acts as closing button
                playerCreationExpanded = false  //closes player creation and resets it
                addPlayerPage.reset()
            } else
                playerCreationExpanded = true   //opens player creation
        }

        z: 2    //hovers over the entire layout
        visible: true   //necessary if not running on Android
    }

    AddPlayerPage {
        id: addPlayerPage

        onPlayerCreated: {
            DataModel.addPlayer(player)     //add player to the data model
            playerCreationExpanded = false  //collapses player creation
            reset()                         //resets player creation
        }

        opacity: playerCreationExpanded ? 1 : 0     //only opaque when expanded
        Behavior on opacity {                       //smooth transition from transparent to opaque
            NumberAnimation {
                easing.type: Easing.InOutSine
                duration: 200
            }
        }

        y: playerCreationExpanded ? 0 : 2 * height  //lets player creation fly in and out
        Behavior on y {                             //again, smooth transitions
            NumberAnimation {
                easing.type: Easing.OutExpo
                duration: 200
            }
        }

        z: 1    //player creation hovers above list
    } //AddPlayerPage

    ListPage {
        id: playersList

        title: "Players"

        emptyText.text: "No Players in Session"     //gets displayed when there are no players in the list
        model: DataModel.getListModel()     //fetches initial data

        delegate: SimpleRow {
            detailTextItem.color: Theme.tintColor
        }
    }//ListPage

    FastBlur {
        id: blur
        source: playersList
        anchors.fill: playersList

        radius: playerCreationExpanded ? 20 : 0 //blur list when player creation is expanded
        Behavior on radius {                    //and add a fancy smooth transition
            NumberAnimation {
                easing.type: Easing.OutExpo
                duration: 200
            }
        }
    }

}