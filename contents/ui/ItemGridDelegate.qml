import QtQuick 2.6

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0

// for using ColumnLayout
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0

import "../code/tools.js" as Tools

Item {
    id: item

    width: GridView.view.cellWidth
    height: GridView.view.cellHeight

    property bool showLabel: true
    property bool showToolTips: plasmoid.configuration.tooltipsInGrid

    readonly property int itemIndex: model.index
    readonly property url url: model.url != undefined ? model.url : ""
    property bool pressed: false
    readonly property bool hasActionList: ((model.favoriteId != null)
                                           || (("hasActionList" in model) && (model.hasActionList == true)))

    Accessible.role: Accessible.MenuItem
    Accessible.name: model.display != undefined ? model.display : ""
    Accessible.description: model.description != undefined ? model.description : ""

    function openActionMenu(x, y) {
        var actionList = hasActionList ? model.actionList : [];
        Tools.fillActionMenu(i18n, actionMenu, actionList, GridView.view.model.favoritesModel, model.favoriteId);
        actionMenu.visualParent = item;
        actionMenu.open(x, y);
    }

    function actionTriggered(actionId, actionArgument) {

        // We send the information about the name of the app that triggered the action, its description as well as the url for finding it (for restoring)
        var data = []
        data["name"] = model.display != undefined ? model.display : ""
        data["description"] = model.description != undefined ? model.description : ""
        data["url"] = model.url != undefined ? model.url : ""
        // horrible line sry
        var iconString = model.decoration.toString().split('"')

        data["icon"] = iconString[1]

        Tools.triggerAction(plasmoid, GridView.view.model, model.index, actionId, actionArgument);

        return data
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

    Column {
        anchors.fill: parent
        bottomPadding: units.largeSpacing
        topPadding: units.largeSpacing

        PlasmaCore.IconItem {
            id: icon
            animated: false
            usesPlasmaTheme: item.GridView.view.usesPlasmaTheme
            source: model.decoration
            height: parent.height - parent.topPadding - parent.bottomPadding - labelLoader.height * labelLoader.active
            width: height
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Loader {
            id: labelLoader
            active: showLabel
            height: active ? t_metrics.height * plasmoid.configuration.labelLines : 0
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
                    maximumLineCount: plasmoid.configuration.labelLines

                    text: model.display != undefined ? model.display : ""
                    padding: units.smallSpacing * 2

                    background: Rectangle {
                        z: -1
                        width: parent.contentWidth + units.largeSpacing
                        height: parent.contentHeight + units.smallSpacing
                        anchors.centerIn: parent
                        color: Qt.rgba(theme.backgroundColor.r, theme.backgroundColor.g, theme.backgroundColor.b,  plasmoid.configuration.labelTransparency)
                        visible: plasmoid.configuration.showLabelBackground
                        radius: 4
                    }

                }
            }

            TextMetrics { // tool get font's height so as to define rectangle's height
                id: t_metrics
                text: model.display != undefined ? model.display : "" // use a text long enough to hold a meaningful query
            }
        }

        PlasmaCore.ToolTipArea {
            id: delegateTooltip
            mainText: model.display != undefined ? model.display : ""
            subText: model.description != undefined ? model.description : ""
            //subText: model.url != undefined ? model.url : "" // debugging option for future stuff.
            interactive: false
        }

    }

    Keys.onPressed: {
        if (event.key == Qt.Key_Menu && hasActionList) {
            event.accepted = true;
            openActionMenu(item);
        } else if ((event.key == Qt.Key_Enter || event.key == Qt.Key_Return)) {
            event.accepted = true;
            GridView.view.model.trigger(index, "", null);
            root.toggle();

        }
    }
}
