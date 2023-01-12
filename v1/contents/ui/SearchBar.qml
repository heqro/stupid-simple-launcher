import QtQuick 2.4

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

// for using TextFieldStyle
import QtQuick.Controls.Styles 1.4

// user information is called by using this
import org.kde.kcoreaddons 1.0 as KCoreAddons

PlasmaComponents.TextField { //searchbar

    id: searchBar

    // Properties inherited from parent object to customize the TextField
        // Whether or not the user wants to set a custom greeting text
    required property bool writeSomething
    required property string greetingText
        // Which design to load
    required property string searchBarDesign
        // Property used by certain designs where its background's transparency can be tweaked
    required property real searchBarOpacity

    // Properties to consult from outside the scope of this element
        // The width it needs
    readonly property int usedSpace: designChooser.active ? designChooser.width : parent.width
    readonly property bool isSearchBarFocused: activeFocus || text != ""

    // we expose this property to be able to run much more powerful tests involving the designs the loader can load
    readonly property Loader design: designChooser

    KCoreAddons.KUser { // this is needed for the greeting message (saying hello whatever the user name is)
        id: kuser
    }

    font.pointSize: theme.defaultFont.pointSize * 2

    placeholderText: (designChooser.active && designChooser.status == Loader.Ready) ? designChooser.item.getPlaceHolderText() : (writeSomething ? greetingText : "Howdy, " + kuser.loginName + "! Type to start searching...")

    horizontalAlignment: (designChooser.active && designChooser.status == Loader.Ready) ? designChooser.item.getHorizontalAlignment() : TextInput.AlignHCenter

    style: TextFieldStyle {

        textColor: theme.headerTextColor
        placeholderTextColor: Qt.rgba(theme.headerTextColor.r, theme.headerTextColor.g, theme.headerTextColor.b, 0.8)

        background: Rectangle {
            color: "transparent"
        }

    }

    Loader {
        id: designChooser

        readonly property int parentHeight: parent.height // propagate this property so that each and every design can make use of it (without explicitly assigning a value to the Loader element because it will affect loaded elements' dimensions.)
        property alias parentText: searchBar.text // we want parentText to be exactly the same as the search bar's text. I am using this property alias because some search bar designs make use of it for their buttons & functionality (such as clearing the query text).
        readonly property bool isSearchBarFocused: parent.isSearchBarFocused

        z: -1 // draw everything under the parent
        active: searchBarDesign != ""
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.bottom
        }
        source: searchBarDesign

        function toggleFocus() { // This function is called to request toggling focus from certain search bar designs (say, those featuring a button to collapse the search bar)
            parent.focus = !parent.focus
            parentText = ""
        }
    }
    function toggleFocus() { // this allows to clear the text within the config module
        designChooser.toggleFocus()
    }

    function unfocus() {
        focus = false
        designChooser.parentText = ""
    }
}
