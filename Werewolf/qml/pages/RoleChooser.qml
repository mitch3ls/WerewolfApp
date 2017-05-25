import VPlayApps 1.0
import QtQuick 2.0
import QtQuick.Layouts 1.1

import "../model"

Page {
    id: roleChooser

    backgroundColor: "transparent" //makes the background transparent

    signal roleSelected(string role)

    function reset() {
        roleList.selected = "" //reset selected role
        title.text = "Choose a Role" //resets title text
    }

    Rectangle {
        id: content

        anchors.centerIn: parent

        Rectangle {
            id: titleWrapper //box around the title

            color: Theme.colors.tintColor

            width: roleList.width //adjusts width to the lists width
            height: 100

            anchors.bottom: roleList.top //sits on top of the list's box
            anchors.horizontalCenter: roleList.horizontalCenter //horizontally aligned with the list

            Text {
                id: title

                text: "Choose a Role"
                font.pixelSize: 40

                color: "white"

                anchors.centerIn: parent
            }
        }

        GridLayout {
            id: roleList

            /*
                The user has to confirm his selection because he might accidentally select a role,
                that he didnt want to select, which might get really frustrating when there are more
                than just 4 roles to choose from
            */

            property string selected: "" //selected role

            width: 400
            height: 400

            rowSpacing: 0 //no spaces between role cards
            columnSpacing: 0

            columns: 2 //2 cards in one row

            anchors.centerIn: parent

            function select(role) {
                //selects role and changes the title
                roleList.selected = role
                title.text = role
            }

            Repeater {
                model: RoleList {
                }

                delegate: AppButton {
                    minimumWidth: 200
                    minimumHeight: 200

                    verticalMargin: 0 //no spaces between role cards
                    horizontalMargin: 0

                    text: name //display the role's name, might be replaced by images
                    textSize: 20
                    fontBold: false //would be bold on Android
                    textColor: isSelected(
                                   ) ? Theme.colors.tintColor : "black" //changes the text's color if role is selected

                    borderColor: Theme.colors.tintColor
                    backgroundColor: "white"

                    onClicked: {
                        if (isSelected())
                            //if the role is selected already
                            roleSelected(name) //submit it
                        else
                            //if not
                            roleList.select(name) //select it
                    }

                    function isSelected() {
                        return roleList.selected === name
                    }

                    Rectangle {
                        z: -1           //white background for ios
                        color: "white"
                        anchors.fill: parent
                    }
                }
            }
        }
        Rectangle {
            id: hintWrapper //hints users to confirm their selection

            color: Theme.colors.tintColor

            width: roleList.width //adjusts width to the list's width

            height: (roleList.selected === "") ? 0 : 50 //expand box if a role is selected
            Behavior on height {
                //smooth transitions <3
                NumberAnimation {
                    duration: 200
                }
            }

            opacity: (height > 0) ? 1 : 0 //visible as soon as the height is greater than zero

            /*
               actually no smooth transition of the opacity this time, because
               I wanted the card to come out of the back of the list
            */

            anchors.top: roleList.bottom    //attaches it to the bottom of the list
            anchors.horizontalCenter: roleList.horizontalCenter //centers it

            Text {
                id: hint

                text: "tab again to confirm selection"
                font.pixelSize: 20

                color: "white"

                anchors.centerIn: parent
            }
        }
    }
}
