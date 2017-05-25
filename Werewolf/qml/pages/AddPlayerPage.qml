import VPlayApps 1.0
import QtQuick 2.0
import QtQuick.Layouts 1.1

import "../model"

Page {
    id: addPlayerDialogue

    title: "Add Player"

    signal playerCreated(var player)

    property var selectedRole: null //initially no role is selected

    backgroundColor: "transparent"  //makes the backkground transparent

    function reset() {
        nameField.text = ""                 //resets nameField
        roleButton.text = "Choose Role"     //resets roleButton
        selectedRole = null                 //resets selectedRole
        error.hide()                        //hides error notifcation
        roleChooser.hide()                  //hides roleChooser PopUp (only necessary when the user exited without closing the roleChooser)
    }

    Rectangle {
        id: background  //adds back in some background color

        /*
            I couldn't find a way to add some transparency to the tint color without changing it globally,
            so I had to use this workaround
          */

        color: Theme.colors.tintColor
        opacity: 0.5

        anchors.fill: parent
    }

    Rectangle {
        id: contentBackground   //actual background of the dialogue

        color: "white"
        border.color: Theme.colors.tintColor

        width: content.width + 20       //add some padding on all sides
        height: content.height + 20
        radius: 4                       //round off the corners

        anchors.centerIn: parent
    }

    GridLayout {
        id: content

        /*
            I decided to use a GridLayout because the spacing is really easy to implement here
          */

        columns: 1
        rowSpacing: 15

        anchors.centerIn: contentBackground

        AppTextField {
            id: nameField

            borderWidth: 1
            Layout.preferredWidth: 250

            onTextChanged: {        //displays error message if nameField is empty
                if (text === "")
                    error.show()
                else
                    error.hide()
            }

            placeholderText: "Name"
        }

        AppButton {
            id: roleButton  //displays roleChooser

            borderColor: Theme.colors.tintColor
            backgroundColor: "white"
            textColor: Theme.colors.tintColor

            text: "Choose Role"

            onClicked: roleChooser.opacity = 1

            Layout.alignment: Qt.AlignHCenter   //center the button
        }

        Item {
            id: errorWrapper

            width: error.width  //use the error text's width

            visible: opacity > 0    //only visible if opacity is greater than 0

            opacity: error.opacity  //use the error text's opacity
            Behavior on opacity {   //smooth transition
                NumberAnimation {
                    duration: 200
                }
            }

            Layout.alignment: Qt.AlignHCenter //center the error box

            AppText {
                id: error   //displays error message

                opacity: 0  //initially not visible
                color: Theme.colors.tintColor

                text: "Please enter a name!"

                anchors.centerIn: parent

                function show() {
                    opacity = 1
                }

                function hide() {
                    opacity = 0
                }
            }   //error
        } //errorWrapper

        AppButton {
            id: createButton //checks and submits new player data

            text: "Create"

            onClicked: {
                if (selectedRole === null)  //if the role hasn't been selected do nothing
                    return

                var player = {
                    name: nameField.text,       //name is set to the text entered in the nameField
                    role: selectedRole       //role is set to the selectedRole role (that can't be null, because we checked it)
                }

                if (DataModel.isValidPlayerModel(player))   //additionally check whether the DataModel would accept our player
                    playerCreated(player)                   //hand the newly created player object to the parents signalHandler
            }

            Layout.alignment: Qt.AlignHCenter   //center button
        }
    }

    RoleChooser {
        id: roleChooser

        z: 1    //gets displayed above the layout

        onRoleSelected: {
            hide()
            roleButton.text = role  //set the text of roleButton to the selected role
            selectedRole = role     //set selectedRole role to the selected role
        }

        function show() {
            opacity = 1
        }

        function hide() {
            opacity = 0
        }

        visible: opacity > 0    //only visible when the opacity is greater than 0
        scale: opacity          //makes it grow when it pops  up

        opacity: 0              //initially not visible
        Behavior on opacity {   //a smooth transition
            NumberAnimation {
                easing.type: Easing.OutQuart
                duration: 200
            }
        }
    }
}
