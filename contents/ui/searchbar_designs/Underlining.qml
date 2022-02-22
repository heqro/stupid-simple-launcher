import QtQuick 2.4

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Rectangle { // (CONCEPT) line under search field. This should be loaded on demand by the Loader QML type.
    height: Math.floor(units.smallSpacing / 2)
    color: isSearchBarFocused ? colorWithAlpha(theme.buttonFocusColor, 1) : colorWithAlpha(theme.highlightColor, 1)
    width: (t_metrics.width > 0) ? t_metrics.width + Math.ceil(2 * units.largeSpacing) : units.largeSpacing // if the user has written something, then make this rectangle surround it. If the user has not written anything, leave some room for the design to "breathe".

    Behavior on width { SmoothedAnimation {velocity: 2500; easing.type: Easing.OutQuad} } // setting both duration and velocity helps when the user cancels out his search and the greeting text is too long for the velocity to catch up in a good fashion.

    TextMetrics { // this elements allows us to read the width of the user's input text
        id: t_metrics
        text: isSearchBarFocused ? myText : placeholderText
        font.pointSize: PlasmaCore.Theme.defaultFont.pointSize * 2 // account for the arbitrary font size chosen in the parent object.
    }

    anchors.top: parent.bottom
}
