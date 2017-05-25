import VPlayApps 1.0
import QtQuick 2.0

import "pages"
import "model"

Page {
    id: werewolfMainPage

    property bool creationModalExpanded: false

    Connections {
        target: DataModel
        onNewListData: playersList.model = data
    }

    FloatingActionButton {
        icon: IconType.plus

        onClicked: creationModalExpanded = !creationModalExpanded

        z: 2
        visible: true
    }

    AddPlayerPage {
        id: addPlayerPage

        onPlayerCreated: DataModel.addPlayer(player)

        opacity: creationModalExpanded ? 1 : 0
        Behavior on opacity {
            NumberAnimation {
                easing.type: Easing.InOutSine
                duration: 200
            }
        }

        y: creationModalExpanded ? 0 : 2 * height
        Behavior on y {
            NumberAnimation {
                easing.type: Easing.OutExpo
                duration: 200
            }
        }

        z: 1
    }

    ListPage {
        id: playersList

        title: "Players"

        emptyText.text: "No Players in Session"

        model: DataModel.getListModel()
    }
}
