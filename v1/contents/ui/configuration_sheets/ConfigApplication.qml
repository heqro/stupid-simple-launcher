import QtQuick 2.0
import QtQuick.Controls 2.2

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import ".."

Item {
    property alias cfg_applicationButtonHeight: applicationButton.height
    property alias cfg_applicationButtonWidth: applicationButton.width
    property alias cfg_labelLines: labelLines.value

    property alias cfg_tooltipsInGrid: tooltipsInGrid.checked

    readonly property int rulersSize: units.iconSizes.small

    Rectangle { // line around the app
        anchors.fill: applicationButton
        color: "transparent"
        radius: units.smallSpacing
        border.color: theme.highlightColor
        border.width: Math.floor(units.smallSpacing / 2)
    }

    Rectangle { // handle for resizing
        width:  parent.rulersSize
        height: parent.rulersSize
        radius: parent.rulersSize
        color: theme.highlightColor
        anchors.horizontalCenter: applicationButton.horizontalCenter
        anchors.verticalCenter: applicationButton.bottom

        MouseArea {
            readonly property int minimumHeight: 24
            anchors.fill: parent
            drag { target: parent; axis: Drag.YAxis }
            onMouseYChanged: {
                if (drag.active && validHeightRequested(mouseY)) {
                    applicationButton.height = applicationButton.height + mouseY
                }
            }

            function validHeightRequested(variation) {
                return applicationButton.height + variation >= minimumHeight
            }
        }
    }

    Rectangle { // handle for resizing
        width: parent.rulersSize
        height: parent.rulersSize
        radius: parent.rulersSize
        color: theme.highlightColor
        anchors.horizontalCenter: applicationButton.right
        anchors.verticalCenter: applicationButton.verticalCenter

        MouseArea {
            readonly property int minimumWidth: 24
            anchors.fill: parent
            drag { target: parent; axis: Drag.XAxis }
            onMouseXChanged: {
                if (drag.active && validWidthRequested(mouseX)) {
                    applicationButton.width = applicationButton.width + mouseX
                }
            }

            function validWidthRequested(variation) {
                return applicationButton.width + variation >= minimumWidth
            }
        }
    }

    ApplicationButton {
        id: applicationButton
        applicationName: "An application with a really long name"
        applicationIcon: "emblem-favorite"
        applicationDescription: "The application's description"

        showBackground: true
        backgroundOpacity: plasmoid.configuration.labelTransparency
        maximumLineCountForName: labelLines.value
        showLabel: true

        height: plasmoid.configuration.applicationButtonHeight
        width: plasmoid.configuration.applicationButtonWidth

        anchors {
            horizontalCenter: parent.horizontalCenter
            topMargin: units.smallSpacing * 2
        }
    }

    Column {

        spacing: units.smallSpacing
        anchors {
            top: applicationButton.bottom
            horizontalCenter: parent.horizontalCenter
            topMargin: units.smallSpacing * 2
        }

        Row {

            spacing: units.smallSpacing * 2

            Label {
                anchors.verticalCenter: parent.verticalCenter
                text: i18n("Number of lines in labels")
            }

            SpinBox {
                id: labelLines
                from: 1
                to: 3
                stepSize: 1
            }
        }

        CheckBox {
            id: tooltipsInGrid
            text: i18n("Show tooltips when hovering on an application")
        }
    }
}
