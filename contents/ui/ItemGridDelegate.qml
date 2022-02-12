import QtQuick 2.0

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0

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

    Rectangle{
        id: box
        height: parent.height // - 10
        width:  parent.width  // - 10
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        //color:"red"
        //opacity: 0.4
        color:"transparent"
    }

    PlasmaCore.IconItem {
        id: icon
//         y: iconSize*0.02
        //anchors.horizontalCenter: box.horizontalCenter
        anchors.top: box.top
        anchors.left: box.left
        anchors.right: box.right
        //anchors.verticalCenter:   box.verticalCenter
        //width: iconSize
        height: iconSize
        animated: false
        usesPlasmaTheme: item.GridView.view.usesPlasmaTheme
        source: model.decoration
    }

    PlasmaComponents.Label {
        id: label

        visible: showLabel

        anchors {
            top: icon.bottom
            topMargin: units.smallSpacing
            left: box.left
            leftMargin: highlightItemSvg.margins.left
            right: box.right
            rightMargin: highlightItemSvg.margins.right
            bottom: box.bottom
            bottomMargin:highlightItemSvg.margins.bottom
        }

        horizontalAlignment: Text.AlignHCenter

        elide: Text.ElideRight
        wrapMode: Text.WordWrap

        text: model.display != undefined ? model.display : ""
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
