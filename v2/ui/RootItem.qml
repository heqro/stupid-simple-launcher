import QtQuick.Controls 2.0
import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import StupidSimpleLauncher 1.0
import org.kde.plasma.extras 2.0 as PlasmaExtras

ApplicationWindow {
    visible: true

    Rectangle {
        anchors.fill: parent
        color: theme.backgroundColor

        GridView {
            anchors.fill: parent
            model: ApplicationsModel
            delegate: ApplicationEntry {
                height: 100
                width: 100
                appEntry: ApplicationsModel.getApplicationEntryAt(index)
            }
            highlight: PlasmaExtras.Highlight {}
            highlightFollowsCurrentItem: true
            highlightMoveDuration: 0
            focus: true // allows for initial focus
        }
    }

    // visibility: "FullScreen"

}
