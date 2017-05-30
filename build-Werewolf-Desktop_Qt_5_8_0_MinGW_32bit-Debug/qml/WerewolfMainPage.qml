import VPlayApps 1.0
import QtQuick 2.0
import QtGraphicalEffects 1.0

import "model"
import "pages"


/*!
    \qmltype WerewolfMainPage.html WerewolfMainPage
    \inherits Page
    \brief Contains all visual components of the app.

    The WerewolfMainPage contains ever visual element of the app and acts as the
    root page of the app. (Even though it technically isn't)
*/
Page {
    id: werewolfMainPage

    FloatingActionButton {
        id: playerCreationControl

        icon: IconType.plus

        //rotates Icon by 45 degrees when player creation is expanded
        //so it becomes the closing icon
        iconItem.rotation: (addPlayerPage.expanded || modifyPlayerPage.expanded) ? 45 : 0
        Behavior on iconItem.rotation {
            NumberAnimation {
                duration: 200
            }
        }

        onClicked: {
            if (addPlayerPage.expanded || modifyPlayerPage.expanded) {
                //acts as closing button
                addPlayerPage.close() //closes player creation and resets it
                modifyPlayerPage.close()
            } else
                addPlayerPage.open() //opens player creation
        }

        z: 2 //hovers over the entire layout
        visible: true //necessary if not running on Android
    }

    AddPlayerPage {
        id: addPlayerPage
    }

    ModifyPlayerPage {
        id: modifyPlayerPage
    }

    AppListView {
        id: playersList

        emptyText.text: "No Players in Session" //gets displayed when there are no players in the list

        model: DataModel.playersListModel

        section.property: "sectionName"
        section.delegate: SimpleSection {
            style.showDividers: true
            style.dividerHeight: 3
            style.totalHeight: 42
            style.textBottomMargin: style.dividerHeight + 8

            style.dividerColor: Theme.tintColor

            textItem.font.pixelSize: 20
        }

        delegate: SwipeOptionsContainer {

            height: listItem.height //use item's height
            SimpleRow {
                id: listItem

                text: name
                detailText: notes

                textItem.font.bold: true
                detailTextItem.color: Theme.tintColor

                onSelected: modifyPlayerPage.openWithPlayer(playerId)
            }

            rightOption: SwipeButton {  //button that appears when the element is swiped to the left
                icon: IconType.trasho   //trashcan icon
                height: parent.height   //use parent's height
                onClicked: DataModel.removePlayer(playerId)   //remove player when clicked
            }
        } //SwipeOptionsContainer

        add: Transition {
          ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
            NumberAnimation { properties: "scale"; from: 0; to: 1; duration: 200; easing.type: Easing.OutCubic }
          }
        }

        remove: Transition {
          ParallelAnimation {
            NumberAnimation { property: "opacity"; to: 0; duration: 400 }
            NumberAnimation { property: "x"; to: -width ; duration: 200 }
          }
        }
    } //ListPage

    FastBlur {
        id: blur
        source: playersList
        anchors.fill: playersList

        radius: addPlayerPage.expanded ? 10 : 0 //blur list when player creation is expanded
        Behavior on radius {
            //and add a fancy smooth transition
            NumberAnimation {
                easing.type: Easing.OutExpo
                duration: 200
            }
        } //Behavior
    } //FastBlur
}
