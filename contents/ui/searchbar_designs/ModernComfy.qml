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
        text: "Some query I would make"
        font.pointSize: PlasmaCore.Theme.defaultFont.pointSize * 2 // account for the arbitrary font size chosen in the parent object.
    }

    Rectangle {

        id: searchIconContainer
        height: isSearchBarFocused ? Math.floor(9 * parent.height / 11) : parent.height
        width:  isSearchBarFocused ? Math.floor(9 * parent.height / 11) : parent.height
        Behavior on width { SmoothedAnimation {duration: 300; easing.type: Easing.OutQuad} }
        Behavior on height { SmoothedAnimation {duration: 300; easing.type: Easing.OutQuad} }

        color: isSearchBarFocused ? colorWithAlpha(theme.buttonHoverColor, 1) : colorWithAlpha(theme.buttonBackgroundColor, 1)

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

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                parentText = isSearchBarFocused ? "" : " " // preemptively empty query text (we won't need it under any case). If the search bar is not focused we force it to be focused by manually adding a whitespace that won't interfere with the search results and is not registered by the textfield anyway.
            }
            onEntered: {
                parent.color = isSearchBarFocused ? colorWithAlpha(theme.buttonHoverColor, 0.5) : colorWithAlpha(theme.buttonBackgroundColor, 0.5)
            }
            onExited: {
                parent.color = isSearchBarFocused ? colorWithAlpha(theme.buttonHoverColor, 1) : colorWithAlpha(theme.buttonBackgroundColor, 1)
            }

        }

    }

    Rectangle { // this is the real rectangle that draws the border around every element in the menu.
        id: borderingRectangle
        z: -1 // set this element under the parent element
        height: parentHeight

        anchors.left: parent.left

        width: parent.width + searchIconContainer.width + units.iconSizes.small

        radius: width/2

        color: colorWithAlpha(theme.backgroundColor, 1)
        opacity: isSearchBarFocused

    }

    // Send visual info to the SearchBar so as to customize it
    function getPlaceHolderText() {
        return ""
    }

    function getHorizontalAlignment() {
        return TextInput.AlignLeft
    }

}
