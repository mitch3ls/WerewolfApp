import VPlayApps 1.0
import QtQuick 2.0
import QtQuick.Layouts 1.1

Page {

    id: addPlayerDialogue

    title: "Add Player"

    signal playerCreated(var player)

    GridLayout {

        columns: 1
        rowSpacing: 30
        anchors.centerIn: parent

        AppTextField {
            id: nameField

            borderWidth: 1

            placeholderText: "Name"
        }

        AppTextField {
            id: roleField

            borderWidth: 1

            placeholderText: "Role"
        }

        AppButton {
            id: createButton

            text: "Create"

            onClicked: {
                var player = {
                    name: nameField.getText(),
                    role: roleField.getText()
                }

                navigationStack.pop();
                playerCreated(player)
            }

            Layout.alignment: Qt.AlignHCenter
        }
    }
}
