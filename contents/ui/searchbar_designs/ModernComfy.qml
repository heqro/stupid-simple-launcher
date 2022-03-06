import QtQuick 2.4

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

// user information is called by using this
import org.kde.kcoreaddons 1.0 as KCoreAddons

Rectangle { // Inspired by modern, cool, responsive search bars

    height: parentHeight
    color: "transparent"
    width: isSearchBarFocused ? t_metrics.width + Math.ceil(1.25 * units.largeSpacing) : 0
    anchors.bottom: parent.top

    Behavior on width { SmoothedAnimation {velocity: 1000; easing.type: Easing.OutQuad} }

    TextMetrics { // this elements allows us to read the width of the user's input text
        id: t_metrics
        text: "Some query I would make" // use a text long enough to hold a meaningful query
        font.pointSize: PlasmaCore.Theme.defaultFont.pointSize * 2 // account for the arbitrary font size chosen in the parent object.
    }

    Rectangle {

        id: searchIconContainer
        height: parent.width > 0 ? Math.floor(9 * parent.height / 11) : parent.height
        width:  parent.width > 0 ? Math.floor(9 * parent.height / 11) : parent.height
        Behavior on width { SmoothedAnimation {duration: 300; easing.type: Easing.OutQuad} }
        Behavior on height { SmoothedAnimation {duration: 300; easing.type: Easing.OutQuad} }

        color: parent.width > 0 ? colorWithAlpha(theme.highlightColor, Math.min(!hoverArea.containsMouse + 0.75, 1)) : colorWithAlpha(theme.buttonBackgroundColor, Math.min(!hoverArea.containsMouse + 0.75, 1))

        Behavior on color {
            ColorAnimation {
                duration: 30
            }
        }

        radius: width / 2

        anchors {
            left: parent.right
            verticalCenter: parent.verticalCenter
        }

        PlasmaCore.IconItem { // search icon
            source: "search" // symbolic-like. I enjoy much more this one than a detailed one.
            height: Math.floor(4 * parent.height / 5)
            width:  Math.floor(4 * parent.height / 5)
            anchors.centerIn: parent
        }

        MouseArea { // this is for making the search icon act as some kind of button to collapse the current search or launch a new query
            id: hoverArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                toggleFocus()
            }

        }

    }

    Rectangle { // this is the real rectangle that draws the border around every element in the menu.
        id: borderingRectangle
        z: -1 // set this element under the parent element
        height: parentHeight

        anchors.left: parent.left

        width: parent.width + searchIconContainer.width + units.iconSizes.small * (parent.width > 0)

        radius: width/2

        color: colorWithAlpha(theme.backgroundColor, 1)
        opacity: parent.width > 0

    }

    // Send visual info to the SearchBar so as to customize it
    function getPlaceHolderText() {
        return ""
    }

    // Send text alignment to customize SearchBar
    function getHorizontalAlignment() {
        return TextInput.AlignLeft
    }

}
