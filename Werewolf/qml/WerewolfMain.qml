import VPlayApps 1.0
import QtQuick 2.0

import "."

/*!
    \qmltype Werewolf.html WerewolfMain
    \inherits Page
    \brief Prepares \c Theme and loads \c WerewolfMainPage

    The WerewolfMainPage doesn't directly contain any visual elements. Its whole purpose is to prepare
    the app and load the \c WerewolfMainPage.

    In the \c onInitTheme method the tintColor is set to a brownish colour.
  */
App {
    id: app

    // You get free licenseKeys from https://v-play.net/licenseKey
    // With a licenseKey you can:
    //  * Publish your games & apps for the app stores
    //  * Remove the V-Play Splash Screen or set a custom one (available with the Pro Licenses)
    //  * Add plugins to monetize, analyze & improve your apps (available with the Pro Licenses)
    //licenseKey: "<generate one from https://v-play.net/licenseKey>"

    onInitTheme: {
        Theme.colors.tintColor = "#FFB90D" //brown
    }

    WerewolfMainPage { }
}
