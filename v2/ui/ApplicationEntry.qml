import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Column {
    required property int index
    required property var appEntry

    property string exec: appEntry.exec
    property string comment: appEntry.comment

    PlasmaCore.IconItem {
        source: appEntry.iconName
        anchors.horizontalCenter: parent.horizontalCenter
        height: 42
        width: 42
    }

    PlasmaComponents.Label {
        text: appEntry.entryName
        anchors.horizontalCenter: parent.horizontalCenter
        width: 2 * parent.width / 3
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        maximumLineCount: 3
    }
}
