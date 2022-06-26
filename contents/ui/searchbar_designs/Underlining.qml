import QtQuick 2.4
import org.kde.plasma.core 2.0 as PlasmaCore

// user information is called by using this
import org.kde.kcoreaddons 1.0 as KCoreAddons

Rectangle { // (CONCEPT) line under search field. This should be loaded on demand by the Loader QML type.

    height: Math.floor(units.smallSpacing / 2)
    width: (t_metrics.width > 0) ? t_metrics.width + Math.ceil(2 * units.largeSpacing) : units.largeSpacing // if the user has written something, then make this rectangle surround it. If the user has not written anything, leave some room for the design to "breathe".
    anchors.top: parent.bottom
    color: isSearchBarFocused ? theme.buttonFocusColor : theme.highlightColor

    Rectangle {
        height: parentHeight
        anchors.bottom: parent.top
        radius: 2
        width: parent.width
        color: Qt.rgba(theme.backgroundColor.r,theme.backgroundColor.g,theme.backgroundColor.b,searchBarOpacity)
    }

    TextMetrics { // dummy metrics to help keep the height of the search bar
        id: dummyMetrics
        text: 'Dummy text'
        font.pointSize: theme.defaultFont.pointSize * 2 // account for the arbitrary font size chosen in the parent object.
    }


    TextMetrics { // this elements allows us to read the width of the user's input text
        id: t_metrics
        text: isSearchBarFocused ? parentText : placeholderText
        font.pointSize: theme.defaultFont.pointSize * 2 // account for the arbitrary font size chosen in the parent object.
    }


    KCoreAddons.KUser { // this is needed for the greeting message (saying hello whatever the user name is)
        id: kuser
    }

    Behavior on width { SmoothedAnimation {velocity: 2500; easing.type: Easing.OutQuad} } // setting both duration and velocity helps when the user cancels out his search and the greeting text is too long for the velocity to catch up in a good fashion.

    // Send visual info to the SearchBar so as to customize it
    function getPlaceHolderText() {
        const text = writeSomething ? greetingText : "Howdy, " + kuser.loginName + "! Type to start searching..."
        return text
    }

    function getHorizontalAlignment() {
        return TextInput.AlignHCenter
    }
}
