import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
// for using the button itself
import org.kde.plasma.components 3.0 as PlasmaComponents

PlasmaComponents.Button {

    property string iconUrl
    property string commandToLaunch
    property string actionName
    property bool showButtonTooltip

    flat: true
    icon.name: iconUrl
    icon.height: units.iconSizes.large
    icon.width: units.iconSizes.large

    PlasmaCore.ToolTipArea {
        id: toolTip
        mainText: actionName
        anchors.fill: parent
        active: showButtonTooltip
    }

    Connections {
        target: root
        function onVisibleChanged() {
            toolTip.hideToolTip()
        }
    }

    onClicked: {
        root.toggle() // make sure we hide this application prior to showing the fullscreen leave menu (or leave, this will depend on whether or not the user has set in its settings to skip the fullscreen leave menu)
        executable.exec(commandToLaunch)
    }
}
