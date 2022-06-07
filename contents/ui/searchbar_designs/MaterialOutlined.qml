import QtQuick 2.4

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3

// user information is called by using this
import org.kde.kcoreaddons 1.0 as KCoreAddons

Rectangle { // (CONCEPT) Inspired on https://material.io/components/text-fields

    height: parentHeight
    color: Qt.rgba(theme.backgroundColor.r,theme.backgroundColor.g,theme.backgroundColor.b, alphaValue * 0.6)

    readonly property real linesWidth: Math.floor(units.smallSpacing / 2)

    radius: Math.ceil(1.75 * units.smallSpacing)
    width: t_metrics.width + Math.ceil(1.25 * units.largeSpacing)

    TextMetrics { // this elements allows us to read the width of the user's input text
        id: t_metrics
        text: placeholderText
        font.pointSize: theme.defaultFont.pointSize * 2 // account for the arbitrary font size chosen in the parent object.
    }

    anchors.bottom: parent.top

    Rectangle { // South line
        id: southLine
        height: linesWidth
        width: parent.width

        anchors.top: parent.bottom
    }

    Rectangle { // West line
        id: westLine
        height: parent.height
        width: linesWidth

        anchors.left: parent.left
    }

    Rectangle { // East line
        id: eastLine
        height: parent.height
        width: linesWidth

        anchors.right: parent.right
    }

    Rectangle {
        id: northLeftLine
        height: linesWidth
        width: units.largeSpacing

        anchors {
            bottom: parent.top
            left: parent.left
        }
    }

    Rectangle { // North line (right side)
        id: northRightLine
        height: linesWidth
        width: isSearchBarFocused ? parent.width - (upperSideMetrics.width * 1.25 + northLeftLine.width) : parent.width

        anchors {
            bottom: parent.top
            right: parent.right
        }

        Behavior on width { SmoothedAnimation { // Show and hide the upper label in the right time
            velocity: 250
            easing.type: Easing.OutQuad
            onRunningChanged: {
                if (isSearchBarFocused && !running)
                    textOnFocus.opacity = 1
                if (!isSearchBarFocused && running)
                    textOnFocus.opacity = 0
            }
        } }

    }

    PlasmaComponents3.Label {
        id: textOnFocus
        text: "Search"

        anchors.verticalCenter: northLeftLine.verticalCenter
        anchors.left: northLeftLine.right
        anchors.leftMargin: upperSideMetrics.width * 0.125
    }

    TextMetrics {
        id: upperSideMetrics
        text: textOnFocus.text
        font.pointSize: PlasmaCore.Theme.defaultFont.pointSize
    }

    Connections {

        target: parent

        function onIsSearchBarFocusedChanged() { // this function avoids to have 5 bindings for just swapping a color

            const color = isSearchBarFocused ? Qt.rgba(theme.buttonFocusColor.r,theme.buttonFocusColor.g,theme.buttonFocusColor.b, 1) : Qt.rgba(theme.highlightColor.r,theme.highlightColor.g,theme.highlightColor.b, 1)

            northLeftLine.color  = color
            northRightLine.color = color
            westLine.color       = color
            eastLine.color       = color
            southLine.color      = color
        }

        Component.onCompleted: onIsSearchBarFocusedChanged()
    }

    KCoreAddons.KUser { // this is needed for the greeting message (saying hello whatever the user name is)
        id: kuser
    }

    // Send visual info to the SearchBar so as to customize it
    function getPlaceHolderText() {
        var text = writeSomething ? greetingText : "Howdy, " + kuser.loginName + "! Type to start searching..."
        return text
    }

    function getHorizontalAlignment() {
        return TextInput.AlignHCenter
    }

    Component.onCompleted: {
        textOnFocus.opacity = isSearchBarFocused
    }

}
