import QtQuick 2.4

import org.kde.plasma.core 2.0 as PlasmaCore

// user information is called by using this
import org.kde.kcoreaddons 1.0 as KCoreAddons

Item { // (CONCEPT) Fully-fledged Gnome-like design.

    height: parentHeight
    width: (t_metrics.width > 0) ? t_metrics.width + Math.ceil(units.largeSpacing * 2) : Math.ceil(units.largeSpacing * 2) // if the user has written something, then make this rectangle surround it. If the user has not written anything, leave some room for the design to "breathe".

    Behavior on width { SmoothedAnimation {velocity: 2500; easing.type: Easing.OutQuad} } // velocity makes it fast. Easing makes it smooth when there is a lot of variation on the text's length for some reason.

    TextMetrics { // this elements allows us to read the width of the user's input text
        id: t_metrics
        text: isSearchBarFocused ? parentText : placeholderText
        font.pointSize: theme.defaultFont.pointSize * 2 // account for the arbitrary font size chosen in the parent object.
    }

    anchors {
        bottom: parent.top
    }

    Item {
        id: searchIconContainer
        height: parentHeight
        width: parentHeight

        anchors.right: parent.left

        PlasmaCore.IconItem {
            source: "nepomuk" // symbolic-like. I enjoy much more this one than a detailed one.
            height: Math.floor(4 * parent.height / 5)
            width: Math.floor(4 * parent.height / 5)
            anchors.centerIn: parent
        }

    }

    Rectangle { // this is the real rectangle that draws the border around every element in the menu.
        id: borderingRectangle
        z: -1 // set this element under the parent element
        height: parentHeight
        width: searchIconContainer.width + parent.width + units.smallSpacing/2

        border.color: isSearchBarFocused ? theme.buttonFocusColor : theme.highlightColor
        border.width: Math.floor(units.smallSpacing/2)
        color: Qt.rgba(theme.backgroundColor.r,theme.backgroundColor.g,theme.backgroundColor.b, searchBarOpacity)
        radius: 40

        anchors.right: parent.right

    }

    KCoreAddons.KUser { // this is needed for the greeting message (saying hello whatever the user name is)
        id: kuser
    }

    // Send visual info to the SearchBar so as to customize it
    function getPlaceHolderText() {
        return writeSomething ? greetingText : "Howdy, " + kuser.loginName + "! Type to start searching..."
    }

    function getHorizontalAlignment() {
        return TextInput.AlignHCenter
    }

}
