import VPlayApps 1.0
import QtQuick 2.0
import QtQuick.Layouts 1.1

import "../model"

Page {
    id: addPlayerDialogue

    title: "Add Player"

    signal playerCreated(var player)

    backgroundColor: "transparent"

    Rectangle {
        id: modal
        anchors.centerIn: parent
        color: "white"
        border.color: Theme.colors.tintColor
        width: content.width + 20
        height: content.height + 20
        radius: 4
    }

    GridLayout {
        id: content

        columns: 1
        rowSpacing: 30
        anchors.centerIn: modal

        AppTextField {
            id: nameField

            borderWidth: 1
            Layout.preferredWidth: 250

            placeholderText: "Name"
        }

        AppTextField {
            id: roleField

            borderWidth: 1
            Layout.preferredWidth: 250

            placeholderText: "Role"
        }

        AppButton {
            id: createButton

            text: "Create"

            onClicked: {
                var player = {
                    name: nameField.text,
                    role: roleField.text
                }

                DataModel.addPlayer(player)
            }

            Layout.alignment: Qt.AlignHCenter
        }
    }
}

