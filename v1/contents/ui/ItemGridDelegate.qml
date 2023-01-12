import QtQuick 2.4

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0

// for using ColumnLayout
import QtQuick.Layouts 1.1

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


    PlasmaCore.IconItem {
        id: icon
        animated: false
        usesPlasmaTheme: item.GridView.view.usesPlasmaTheme
        source: model.decoration
        height: parent.height - labelLoader.height * labelLoader.active
        width: parent.height
        anchors.top: parent.top

    }

    Loader {
        id: labelLoader
        active: showLabel
        height: active ? t_metrics.height * 2 + units.smallSpacing/3 : 0// allow a maximum of three
        width: active ? parent.width : 0
        anchors.top: icon.bottom

        sourceComponent: Item {

            id: labelBoundary
            anchors.fill: parent
            PlasmaComponents.Label {

                id: label
                visible: showLabel

                anchors.fill: parent
                anchors.leftMargin:     units.smallSpacing/2
                anchors.rightMargin:    units.smallSpacing/2
                anchors.bottomMargin:   units.smallSpacing/3


                horizontalAlignment: Text.AlignHCenter

                elide: Text.ElideRight
                wrapMode: Text.WordWrap
                maximumLineCount: 2

                text: model.display != undefined ? model.display : ""

                Rectangle {
                    z: -1
                    width: Math.min(label.contentWidth + units.smallSpacing * 2, item.width)
                    height: label.implicitHeight
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
