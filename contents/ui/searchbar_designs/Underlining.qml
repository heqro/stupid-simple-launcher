import QtQuick 2.4

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Rectangle { // (CONCEPT) line under search field. This should be loaded on demand by the Loader QML type.
    height: Math.floor(units.smallSpacing / 2)
    color: Qt.rgba(theme.highlightColor.r,theme.highlightColor.g,theme.highlightColor.b, 1)
    width: (t_metrics.width > 0) ? t_metrics.width + Math.ceil(1.25 * units.smallSpacing) : 0

    Behavior on width { SmoothedAnimation {duration: 300; velocity: 200} } // setting both duration and velocity helps when the user cancels out his search and the greeting text is too long for the velocity to catch up in a good fashion.

    TextMetrics { // this elements allows us to read the width of the user's input text
        id: t_metrics
        text: (myText != "") ? myText : placeholderText
        font.pointSize: 20 // account for the arbitrary font size chosen in the parent object.
    }

    anchors.top: parent.bottom
}
