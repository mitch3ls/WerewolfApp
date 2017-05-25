import VPlayApps 1.0
import QtQuick 2.0

ListModel {
    id: roles

    ListElement { name: "Werewolf"}
    ListElement { name: "Villager"}
    ListElement { name: "Seer"}
    ListElement { name: "Witch"}

    function roleExists(role) { //returns whether a given role exists or not
        for (var i = 0; i < roles.count; i++) {
            if (role === roles.get(i)) return true
        }
        return false
    }
}
