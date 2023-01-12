import QtQuick 2.4
// QtQuick 2.4 -> TextMetrics, getHorizontalAlignment(), getPlaceHolderText()

import org.kde.plasma.core 2.0 as PlasmaCore

// user information is called by using this
import org.kde.kcoreaddons 1.0 as KCoreAddons

Item { // Inspired by modern, cool, responsive search bars

    // expose important properties for launching our tests
    readonly property Rectangle searchIconCircle: searchIconContainer

    height: parentHeight
    width: isSearchBarFocused ? t_metrics.width + Math.ceil(1.25 * units.largeSpacing) : 0
    anchors.bottom: parent.top

    Behavior on width { SmoothedAnimation {duration: 500; easing.type: Easing.OutQuad} }

    TextMetrics { // this elements allows us to read the width of the user's input text
        id: t_metrics
        text: "Some query I would make" // use a text long enough to hold a meaningful query
        font.pointSize: theme.defaultFont.pointSize * 2 // account for the arbitrary font size chosen in the parent object.
    }

    Rectangle {

        id: searchIconContainer
        height:Math.floor(9 * parent.height / 11)
        width: Math.floor(9 * parent.height / 11)
        color: Qt.rgba(theme.highlightColor.r,theme.highlightColor.g,theme.highlightColor.b, Math.min(!hoverArea.containsMouse + 0.75, 1))
        radius: width / 2

        anchors {
            left: parent.right
            verticalCenter: parent.verticalCenter
        }

        PlasmaCore.IconItem { // search icon
            source: "nepomuk" // symbolic-like. I enjoy much more this one than a detailed one.
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
        height: parent.width > 0 ?  parentHeight : Math.floor(9 * parent.height / 11)

        anchors.right: searchIconContainer.right
        anchors.rightMargin: -units.iconSizes.small * (parent.width > 0)

        states: [
            State {
                name: "increaseMargin"
                when: isSearchBarFocused
                PropertyChanges {
                    target: borderingRectangle
                    anchors.rightMargin: -units.iconSizes.small
                }
            },
            State {
                name: "decreaseMargin"
                when: !isSearchBarFocused
                PropertyChanges {
                    target: borderingRectangle
                    anchors.rightMargin: 0
                }
            }
        ]

        transitions: [
            Transition {
                to: "increaseMargin"
                NumberAnimation { properties:"anchors.rightMargin"; easing.type: Easing.OutQuad;duration: 750 }
            },
            Transition {
                to: "decreaseMargin"
                NumberAnimation { properties:"anchors.rightMargin"; easing.type: Easing.OutQuad;duration: 750 }
            }
        ]

        anchors.verticalCenter: parent.verticalCenter

        width: isSearchBarFocused ? t_metrics.width + Math.ceil(1.25 * units.largeSpacing) + searchIconContainer.width + units.iconSizes.small : searchIconContainer.width // calculating our own width instead of using this element's parent. This allows to launch both the parent and this element's animation at the same time. (HACK?)

        Behavior on width { SmoothedAnimation {duration: 500; easing.type: Easing.OutQuad} }

        radius: width/2

        //color: "red" // for debugging purposes
        color: theme.backgroundColor
        border.color: theme.highlightColor
        border.width: Math.floor(units.smallSpacing/2)

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
