import QtQuick 2.6
import QtQuick.Controls 2.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Column {
    property string applicationName
    property var applicationIcon
    property string applicationDescription

    property bool showBackground
    property real backgroundOpacity

    property int maximumLineCountForName

    property bool showLabel

    bottomPadding: units.largeSpacing
    topPadding: units.largeSpacing

    PlasmaCore.IconItem {
        id: icon
        usesPlasmaTheme: false
        source: applicationIcon
        height: parent.height - parent.topPadding - parent.bottomPadding - labelLoader.height * labelLoader.active
        width: height
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Loader {
        id: labelLoader
        active: showLabel
        height: active ? t_metrics.height * maximumLineCountForName : 0
        width: active ? parent.width - units.largeSpacing : 0
        anchors.horizontalCenter: parent.horizontalCenter

        sourceComponent: Item {

            id: labelBoundary
            anchors.fill: parent

            Label {

                id: label
                visible: showLabel

                anchors.centerIn: parent
                anchors.leftMargin:     units.smallSpacing/2
                anchors.rightMargin:    units.smallSpacing/2
                anchors.bottomMargin:   units.smallSpacing/3
                width: parent.width

                horizontalAlignment: Text.AlignHCenter

                elide: Text.ElideRight
                wrapMode: Text.WordWrap
                maximumLineCount: maximumLineCountForName

                text: applicationName ?? ""
                padding: units.smallSpacing * 2

                background: Rectangle {
                    z: -1
                    width: parent.contentWidth + units.largeSpacing
                    height: parent.contentHeight + units.smallSpacing
                    anchors.centerIn: parent
                    visible: showBackground
                    color: Qt.rgba(theme.backgroundColor.r, theme.backgroundColor.g, theme.backgroundColor.b,  backgroundOpacity)
                    radius: 4
                }

            }
        }

        TextMetrics { // tool get font's height so as to define rectangle's height
            id: t_metrics
            text: applicationName ?? ""
        }
    }

    PlasmaCore.ToolTipArea {
        id: delegateTooltip
        mainText: applicationName ?? ""
        subText: applicationDescription ?? ""
        //subText: model.url != undefined ? model.url : "" // debugging option for future stuff.
        interactive: false
    }

    function showDelegateToolTip(show, now) {
        if (showToolTips) {
            if (show) {
                delegateTooltip.showToolTip()
            } else {
                if (now) {
                    delegateTooltip.hideImmediately()
                } else {
                    delegateTooltip.hideToolTip()
                }
            }
        }
    }
}
