import VPlayApps 1.0
import QtQuick 2.0

import "pages"
import "model"

Page {
    id: werewolfMainPage

    Component {
        id: addPlayerPageComponent
        AddPlayerPage {
            onPlayerCreated: {
                DataModel.addPlayer(player)
            }
        }
    }

//    NewAddPlayerPage  {
//        z: 1

//        visible: true
//        enabled: visible

//        anchors.centerIn: parent
//    }

    NavigationStack {

        ListPage {

            id: playersList

            title: "Players"

            emptyText.text: "No Players in Session"

            FloatingActionButton {
                icon: IconType.plus
                onClicked: playersList.navigationStack.push(
                               addPlayerPageComponent)
                visible: true
            }

            model: DataModel.getListModel()
        }
    }
}
