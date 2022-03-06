import QtQuick 2.4

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

// for using TextFieldStyle
import QtQuick.Controls.Styles 1.4

// user information is called by using this
import org.kde.kcoreaddons 1.0 as KCoreAddons

PlasmaComponents.TextField { //searchbar

    id: searchBar

    property string myText: text
    property int usedSpace: designChooser.active ? designChooser.width : parent.width

    KCoreAddons.KUser { // this is needed for the greeting message (saying hello whatever the user name is)
        id: kuser
    }

    property string greetingMessage: plasmoid.configuration.greetingText


    property bool hasNewTextBeenWritten: false // stupid binding to know if the user has been introduced new text. That way, we update foundNewApps to force a runnerModel update (if new results were found).
    property bool foundNewApps: hasNewTextBeenWritten && runnerModel.count == 1

    font.pointSize: PlasmaCore.Theme.defaultFont.pointSize * 2

    placeholderText: designChooser.active ? designChooser.item.getPlaceHolderText() : (plasmoid.configuration.writeSomething ? plasmoid.configuration.greetingText : "Howdy, " + kuser.loginName + "! Type to start searching...")

    horizontalAlignment: designChooser.active ? designChooser.item.getHorizontalAlignment() : TextInput.AlignHCenter

    style: TextFieldStyle {

        textColor: Qt.rgba(PlasmaCore.Theme.headerTextColor.r, PlasmaCore.Theme.headerTextColor.g, PlasmaCore.Theme.headerTextColor.b,1)
        placeholderTextColor: colorWithAlpha(PlasmaCore.Theme.headerTextColor, 0.8)


        background: Rectangle {
            color: "transparent"
        }

    }

    Loader {
        id: designChooser
        z: -1 // draw this element under parent (TODO - please fix this shit workaround once you know more about QML)
        active: plasmoid.configuration.searchBarDesign != ""
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.bottom
        }

        property int parentHeight: parent.height // propagate this property so that each and every design can make use of it (without explicitly assigning a value to the Loader element because it will affect loaded elements' dimensions.)
        property bool isSearchBarFocused: parent.activeFocus || myText != ""
        property alias parentText: searchBar.text // we want parentText to be exactly the same as the search bar's text. I am using this property alias because some search bar designs make use of it for their buttons & functionality (such as clearing the query text).

        source: plasmoid.configuration.searchBarDesign

        function toggleFocus() { // This function is called to request toggling focus from certain search bar designs (say, those featuring a button to collapse the search bar)
            parent.focus = !parent.focus
            parentText = ""
        }
    }
}
