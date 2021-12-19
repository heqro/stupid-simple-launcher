import QtQuick 2.4
import org.kde.plasma.core 2.0 as PlasmaCore
// for using the button itself
import org.kde.plasma.components 3.0 as PlasmaComponents

// https://doc.qt.io/qt-5/qtquickcontrols2-icons.html

PlasmaComponents.Button {
    property string iconUrl
    property string commandToLaunch
    property string actionName
    flat: true
    icon.name: iconUrl
    icon.height: PlasmaCore.Units.iconSizes.large
    icon.width: PlasmaCore.Units.iconSizes.large
    onClicked: {
        root.toggle() // make sure we hide this application prior to showing the fullscreen leave menu (or leave, this will depend on whether or not the user has set in its settings to skip the fullscreen leave menu)
        executable.exec(commandToLaunch)
    }

    Loader { // only try to load tooltips when the user wants them to load.
        active: plasmoid.configuration.showSessionControlTooltips
        anchors.fill: parent
        sourceComponent: Component {
            PlasmaCore.ToolTipArea {
                mainText: actionName
//                 anchors.fill: parent
            }
        }
    }

}
