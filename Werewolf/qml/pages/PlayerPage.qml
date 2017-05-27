import VPlayApps 1.0
import QtQuick 2.0
import QtQuick.Layouts 1.1

import "../model"

Page {
    id: playerPage

    title: "Add Player"

    signal submit(var player)

    property string title
    property bool expanded

    property alias name: nameField.text
    property alias notes: notes.text
    property alias role: roleChooser.selectedRole
    property alias roleText: roleButton.text

    backgroundColor: "transparent"  //makes the backkground transparent

    function reset() {
        nameField.text = ""                 //resets nameField
        notes.text = ""                     //resets notes
        roleButton.text = "Choose Role"     //resets roleButton
        roleChooser.selectedRole = ""       //resets selectedRole
        error.hide()                        //hides error notifcation
        roleChooser.hide()                  //hides roleChooser PopUp (only necessary when the user exited without closing the roleChooser)
        roleChooser.reset()                 //resets roleChooser
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
        rowSpacing: 10

        anchors.centerIn: contentBackground

        AppTextField {
            id: nameField

            borderWidth: 1
            Layout.preferredWidth: 300

            onTextChanged: {        //displays error message if nameField is empty
                if (text === "")
                    error.show()
                else
                    error.hide()
            }

            placeholderText: "Name"
        }

        AppTextEdit {
            id: notes

            Layout.preferredWidth: 250
            Layout.alignment: Qt.AlignHCenter   //center the button
            wrapMode: TextEdit.Wrap             //start a new line before the text flows out of the parent container

            placeholderText: "Add Notes"

            font.pixelSize: focus ? 20 : 15     //scale text up when focussed
            Behavior on font.pixelSize {        //do it smoothly
                NumberAnimation {
                    duration: 200
                }
            }

            anchors.top: nameField.bottom
            anchors.topMargin: focus ? 15 : 10  //increase the distance between the text and the nameField when focussed
            Behavior on anchors.topMargin {     //do that smoothly as well
                NumberAnimation {
                    duration: 200
                }
            }
        }

        AppButton {
            id: roleButton  //displays roleChooser

            borderColor: Theme.colors.tintColor
            backgroundColor: "white"

            text: "Choose Role"
            fontBold: false //would be bold on Android
            textColor: Theme.colors.tintColor
            textSize: 20

            onClicked: roleChooser.show()
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
            height: 20

            AppText {
                id: error   //displays error message

                function show() {
                    opacity = 1
                }

                function hide() {
                    opacity = 0
                }

                opacity: 0  //initially not visible
                color: Theme.colors.tintColor

                text: "Please enter a name!"

                anchors.centerIn: parent
            }   //error
        } //errorWrapper

        AppButton {
            id: submitButton //checks and submits new player data

            text: title
            fontBold: false //would be bold on Android
            textColor: "white"
            textSize: 25

            onClicked: {
                if (roleChooser.selectedRole === "")  //if the role hasn't been selected do nothing
                    return

                var player = {
                    name: nameField.text,       //name is set to the text entered in the nameField
                    role: roleChooser.selectedRole,       //role is set to the selectedRole role (that can't be null, because we checked it)
                    notes: notes.text
                }

                var roleObject = DataModel.roles.getRoleObject(player.role)
                player.sectionName = (roleObject.pluralName) ? roleObject.pluralName : roleObject.name

                if (DataModel.isValidPlayerModel(player))   //additionally check whether the DataModel would accept our player
                    submit(player)                   //hand the newly created player object to the parents signalHandler
            }

            horizontalMargin: 0
            verticalMargin: 0
            Layout.alignment: Qt.AlignHCenter   //center button

            Rectangle {
                z: -1       //background for ios
                color: Theme.tintColor
                anchors.fill: parent
            }
        }
    }

    RoleChooser {
        id: roleChooser

        function show() {
            opacity = 1
        }

        function hide() {
            opacity = 0
        }

        z: 1    //gets displayed above the layout

        onRoleSelected: {
            hide()
            roleButton.text = selectedRole
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
