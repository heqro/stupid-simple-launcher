import QtQuick 2.4

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Rectangle { // (CONCEPT) Inspired on https://material.io/components/text-fields

    height: parentHeight
    color: "transparent"
    border.color: isSearchBarFocused ? colorWithAlpha(theme.buttonFocusColor, 1) : colorWithAlpha(theme.highlightColor, 1)
    border.width: Math.floor(units.smallSpacing/2)

    radius: Math.ceil(1.75 * units.smallSpacing)
    width: t_metrics.width + Math.ceil(1.25 * units.largeSpacing)

    Behavior on width { SmoothedAnimation {velocity: 2500; easing.type: Easing.OutQuad} } // setting both duration and velocity helps when the user cancels out his search and the greeting text is too long for the velocity to catch up in a good fashion.

    TextMetrics { // this elements allows us to read the width of the user's input text
        id: t_metrics
        text: placeholderText
        font.pointSize: PlasmaCore.Theme.defaultFont.pointSize * 2 // account for the arbitrary font size chosen in the parent object.
    }

    anchors.bottom: parent.top

    Rectangle {
        height: parent.border.width
        width: isSearchBarFocused ? Math.ceil(upperSideMetrics.width * 1.25) : 0
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: Math.floor(parent.radius * 1.75)
        color: colorWithAlpha(theme.backgroundColor, plasmoid.configuration.opacitySet ? plasmoid.configuration.alphaValue : 0.8)

        Behavior on width { SmoothedAnimation {velocity: 500; easing.type: Easing.OutQuad} }


        PlasmaComponents.Label {
            id: textOnFocus
            text: "Search"
            anchors.centerIn: parent
            visible: parent.width == Math.ceil(upperSideMetrics.width * 1.25)
        }

        TextMetrics {
            id: upperSideMetrics
            text: textOnFocus.text
            font.pointSize: PlasmaCore.Theme.defaultFont.pointSize
        }

    }

}
