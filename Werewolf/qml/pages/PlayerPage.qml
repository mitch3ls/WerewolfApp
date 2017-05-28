import VPlayApps 1.0
import QtQuick 2.0
import QtQuick.Layouts 1.1

import "../model"

/*!
    \qmltype PlayerPage
    \inherits Page
    \brief Provides layout and basic functionality for the \c AddPlayerPage and the \c ModifyPlayerPage.

    The PlayerPage contains ever element you see when the \c AddPlayerPage or the \c ModifyPlayerPage is expanded.
    It also processes the input and directly calls submit with the player object (without the playerId).


 */

Page {
    id: playerPage

    /*!
        \qmlsignal PlayerPage::submit(var player)
        \brief Submits created \a player object to derived component.

        When the user presses the submit button ("Create" or "Modify Player") a \a player object is created and passed to
        the derived component's signalHandler.
     */
    signal submit(var player)

    /*!
        \qmlproperty string PlayerPage::title

        The text in the submit button. ("Create" or "Modify Player")
     */
    property string title

    /*!
        \qmlproperty bool PlayerPage::expanded

        Describes whether the PlayerPage is expanded or not.
     */
    property bool expanded

    /*!
        \qmlproperty alias PlayerPage::name

        The text in the name \c AppTextField.
     */
    property alias name: nameField.text

    /*!
        \qmlproperty alias PlayerPage::notes

        The text in the notes \c AppTextEdit.
     */
    property alias notes: notes.text

    /*!
        \qmlproperty alias PlayerPage::role

        The role in the \c roleChooser.
     */
    property alias role: roleChooser.selectedRole

    /*!
        \qmlproperty alias PlayerPage::roleText

        The text in the role button. ("Choose role" if not specified)
     */
    property alias roleText: roleButton.text

    backgroundColor: "transparent"  //makes the background transparent

    /*!
        \qmlmethod PlayerPage::reset()
        \brief Resets the input fields and hides the \c roleChooser.

        Restores default values in all text inputs and hides the \c errorField and the \c roleChooser.
        Calls the \c{roleChooser}'s reset method.
     */
    function reset() {
        nameField.text = ""                 //resets nameField
        notes.text = ""                     //resets notes
        roleButton.text = "Choose Role"     //resets roleButton
        roleChooser.selectedRole = ""       //resets selectedRole
        errorField.hide()                        //hides error notifcation
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
                    errorField.show()
                else
                    errorField.hide()
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

            width: errorField.width  //use the error text's width

            visible: opacity > 0    //only visible if opacity is greater than 0

            opacity: errorField.opacity  //use the error text's opacity
            Behavior on opacity {   //smooth transition
                NumberAnimation {
                    duration: 200
                }
            }

            Layout.alignment: Qt.AlignHCenter //center the error box
            height: 20

            AppText {
                id: errorField   //displays error message

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
                if (nameField.text === "" || roleChooser.selectedRole === "")  //if the name field is empty or the role hasn't been selected do nothing
                    return

                var player = {
                    name: nameField.text,           //name is set to the text entered in the nameField  (can't be empty)
                    role: roleChooser.selectedRole, //role is set to the selectedRole role              (can't be empty)
                    notes: notes.text               //notes is set to the text                          (can be empty)
                }

                var roleObject = DataModel.roles.getRoleObject(player.role) //get the roles object representation
                player.sectionName = (roleObject.pluralName) ?              //if  there is a plural name for that role,
                            roleObject.pluralName :                         //use it as the sectionName
                            roleObject.name                                 //otherwise use the role name

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
