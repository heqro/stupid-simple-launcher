/***************************************************************************
 *   Copyright (C) 2015 by Eike Hein <hein@kde.org>                        *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 2.4

import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kquickcontrolsaddons 2.0
import org.kde.draganddrop 2.0

// vanilla scrollview
import QtQuick.Controls 2.2

FocusScope {
    id: itemGrid

    signal keyNavLeft
    signal keyNavRight
    signal keyNavUp
    signal keyNavDown

    property bool dragEnabled: false
    property bool showLabels: true
    property alias usesPlasmaTheme: gridView.usesPlasmaTheme

    property alias currentIndex: gridView.currentIndex
    property alias currentItem: gridView.currentItem
    property alias contentItem: gridView.contentItem
    property alias count: gridView.count
    property alias flow: gridView.flow
    property alias snapMode: gridView.snapMode
    property alias model: gridView.model

    property alias cellWidth: gridView.cellWidth
    property alias cellHeight: gridView.cellHeight

    property bool rootVisible: root.visible

    readonly property int columns: Math.floor(width / cellWidth)
    readonly property int rows: Math.ceil(count / columns)

    onRootVisibleChanged: {
        // This makes sure that the application tooltip is hidden when the user leaves the menu. We can determine they has left leaves because the root visibility is changed.
        if (currentIndex != -1 && currentItem) {
            currentItem.showDelegateToolTip(false, true)
        }
    }

    onFocusChanged: {
        if (!focus) {
            currentIndex = -1;
        }
    }

    function currentRow() {
        if (currentIndex == -1) {
            return -1;
        }

        return Math.floor(currentIndex / columns);
    }

    function currentCol() {
        if (currentIndex == -1) {
            return -1;
        }

        return currentIndex - (currentRow() * columns);
    }

    function lastRow() {
        return rows - 1;
    }

    function tryActivate(row, col) {
        if (count) {
            row = Math.min(row, rows - 1);
            col = Math.min(col, columns - 1);
            currentIndex = Math.min(row ? ((Math.max(1, row) * columns) + col)
                : col,
                count - 1);

            gridView.forceActiveFocus();
        }
    }

    function forceLayout() {
        gridView.forceLayout();
    }

    ActionMenu {
        id: actionMenu

        onActionClicked: {
            var whoActed = visualParent.actionTriggered(actionId, actionArgument)

            if (actionId == "hideApplication") {

                var addName = plasmoid.configuration.hiddenApplicationsName
                addName.push(whoActed["name"])
                plasmoid.configuration.hiddenApplicationsName = addName

                var addDesc = plasmoid.configuration.hiddenApplicationsDescription
                addDesc.push(whoActed["description"])
                plasmoid.configuration.hiddenApplicationsDescription = addDesc

                var addUrl = plasmoid.configuration.hiddenApplicationsUrl
                addUrl.push(whoActed["url"])
                plasmoid.configuration.hiddenApplicationsUrl = addUrl

                var addIcon = plasmoid.configuration.hiddenApplicationsIcon
                addIcon.push(whoActed["icon"])
                plasmoid.configuration.hiddenApplicationsIcon = addIcon

//                 itemGrid.menuUpdated
            }

            if (actionId == "editApplication" || actionId == "_kicker_jumpListAction" || actionId == "_kicker_recentDocument" || actionId == "runnerAction") {
                root.toggle()
            }
        }
    }

    DropArea {
        id: dropArea

        anchors.fill: parent

        onDragMove: {
            if (!dragEnabled || gridView.animating) {
                return;
            }

            var cPos = mapToItem(gridView.contentItem, event.x, event.y);
            var item = gridView.itemAt(cPos.x, cPos.y);

            if (item && item != kicker.dragSource && kicker.dragSource && kicker.dragSource.parent == gridView.contentItem) {
                item.GridView.view.model.moveRow(dragSource.itemIndex, item.itemIndex);
            }

        }

        Timer {
            id: showToolTipTimer
            interval: 500
            running: true
            onTriggered: { // show tooltip after user has hovered for half a second
                if (mouseAreaView.containsMouse && currentIndex != -1) {
                    //console.log("500 ms have passed") // debugging
                    currentItem.showDelegateToolTip(true, false)
                    showToolTipTimer.stop()
                }
            }
        }

        Timer {
            id: resetAnimationDurationTimer

            interval: 80
            repeat: false

            onTriggered: {
                gridView.animationDuration = interval - 20;
            }
        }

        GridView {
            //this defines how the icons will look like in our menu
            id: gridView
            anchors.fill: parent
            clip: true

            interactive: false // without this line, we cannot swipe sideways!

            property bool usesPlasmaTheme: false

            property bool animating: false
            property int animationDuration: dragEnabled ? resetAnimationDurationTimer.interval : 0

            focus: true
            currentIndex: -1

            move: Transition {
                enabled: itemGrid.dragEnabled

                SequentialAnimation {
                    PropertyAction { target: gridView; property: "animating"; value: true }

                    NumberAnimation {
                        duration: gridView.animationDuration
                        properties: "x, y"
                        easing.type: Easing.OutQuad
                    }

                    PropertyAction { target: gridView; property: "animating"; value: false }
                }
            }

            moveDisplaced: Transition {
                enabled: itemGrid.dragEnabled

                SequentialAnimation {
                    PropertyAction { target: gridView; property: "animating"; value: true }

                    NumberAnimation {
                        duration: gridView.animationDuration
                        properties: "x, y"
                        easing.type: Easing.OutQuad
                    }

                    PropertyAction { target: gridView; property: "animating"; value: false }
                }
            }

            keyNavigationWraps: false
            boundsBehavior: Flickable.StopAtBounds

            delegate: ItemGridDelegate {
                showLabel: showLabels
            }

            highlight: PlasmaExtras.Highlight {}
            highlightFollowsCurrentItem: true
            highlightMoveDuration: 0


            onCountChanged: {
                animationDuration = 0;
                resetAnimationDurationTimer.start();
            }

            onModelChanged: {
                currentIndex = -1;
            }

            Keys.onLeftPressed: {
                if (currentIndex == -1) {
                    currentIndex = 0;
                    return;
                }

                if (currentCol() != 0) {
                    event.accepted = true;
                    moveCurrentIndexLeft();
                } else {
                    itemGrid.keyNavLeft();
                }
            }

            Keys.onRightPressed: {
                if (currentIndex == -1) {
                    currentIndex = 0;
                    return;
                }



                if (currentCol() != columns - 1 && currentIndex != count - 1) {
                    event.accepted = true;
                    moveCurrentIndexRight();
                } else {
                    itemGrid.keyNavRight();
                }
            }

            Keys.onUpPressed: {
                if (currentIndex == -1) {
                    currentIndex = 0;
                    return;
                }

                if (currentRow() != 0) {
                    event.accepted = true;
                    moveCurrentIndexUp();
                    positionViewAtIndex(currentIndex, GridView.Contain);
                } else {
                    itemGrid.keyNavUp();
                }
            }

            Keys.onDownPressed: {
                if (currentIndex == -1) {
                    currentIndex = 0;
                    return;
                }

                if (currentRow() < itemGrid.lastRow()) {
                    // Fix moveCurrentIndexDown()'s lack of proper spatial nav down
                    // into partial columns.
                    event.accepted = true;

                    var newIndex = currentIndex + columns;
                    currentIndex = Math.min(newIndex, count - 1);
                    positionViewAtIndex(currentIndex, GridView.Contain);
                } else {
                    itemGrid.keyNavDown();
                }
            }

        }


        MouseArea {
            id: mouseAreaView

            anchors.fill: parent

            property int pressX: -1
            property int pressY: -1
            property int lastX: -1
            property int lastY: -1
            property Item pressedItem: null

            acceptedButtons: Qt.LeftButton | Qt.RightButton

            hoverEnabled: true

            function updatePositionProperties(x, y) {
                // Prevent hover event synthesis in QQuickWindow interfering
                // with keyboard navigation by ignoring repeated events with
                // identical coordinates. As the work done here would be re-
                // dundant in any case, these are safe to ignore.
                if (lastX == x && lastY == y) {
                    return;
                }

                lastX = x;
                lastY = y;

                if (currentIndex != -1 && currentItem) {
                    currentItem.showDelegateToolTip(false, true)
                }


                var cPos = mapToItem(gridView.contentItem, x, y);
                var item = gridView.itemAt(cPos.x, cPos.y);

                if (!item) {

                    gridView.currentIndex = -1;
                    pressedItem = null;
                } else {
                    gridView.currentIndex = item.itemIndex;
                    itemGrid.focus = (currentIndex != -1)

                    showToolTipTimer.restart()
                }

                return item;
            }



            onPressed: {
                mouse.accepted = true;

                updatePositionProperties(mouse.x, mouse.y);
                pressX = mouse.x;
                pressY = mouse.y;

                if (mouse.button == Qt.RightButton) {
                    if (gridView.currentItem) {
                        if (gridView.currentItem.hasActionList) {
                            var mapped = mapToItem(gridView.currentItem, mouse.x, mouse.y);
                            gridView.currentItem.openActionMenu(mapped.x, mapped.y);
                        }
                    } else {
                        var mapped = mapToItem(rootItem, mouse.x, mouse.y);
                        contextMenu.open(mapped.x, mapped.y);
                    }
                } else {
                    pressedItem = gridView.currentItem;
                }
            }

            onReleased: {
                mouse.accepted = true;

                if (gridView.currentItem && gridView.currentItem == pressedItem) {
                    if ("trigger" in gridView.model) {
                        gridView.model.trigger(pressedItem.itemIndex, "", null);

                        if ("toggle" in root) {
                            root.toggle();
                        } else {
                            root.visible = false;
                        }
                    }
                }

                pressX = -1;
                pressY = -1;
                pressedItem = null;
            }

            onPressAndHold: {
                if (!dragEnabled) {
                    pressX = -1;
                    pressY = -1;
                    return;
                }

                var cPos = mapToItem(gridView.contentItem, mouse.x, mouse.y);
                var item = gridView.itemAt(cPos.x, cPos.y);

                if (!item) {
                    return;
                }

                if (!dragHelper.isDrag(pressX, pressY, mouse.x, mouse.y)) {
                    kicker.dragSource = item;
                    dragHelper.startDrag(kicker, item.url);
                }

                pressX = -1;
                pressY = -1;
                pressedItem = null;
            }

            onPositionChanged: {
                var item = updatePositionProperties(mouse.x, mouse.y);

                if (gridView.currentIndex != -1 && item != null && item.m != null) {
                    if (dragEnabled && pressX != -1 && dragHelper.isDrag(pressX, pressY, mouse.x, mouse.y)) {
                        if ("pluginName" in item.m) {
                            dragHelper.startDrag(kicker, item.url, item.icon,
                            "text/x-plasmoidservicename", item.m.pluginName);
                        } else {
                            dragHelper.startDrag(kicker, item.url, item.icon);
                        }

                        kicker.dragSource = item;

                        pressX = -1;
                        pressY = -1;
                    }
                }
            }

            onContainsMouseChanged: {
                // this whole thing is triggered whenever
                // the user places the cursor inside or outside the apps
                // grid
                if (!containsMouse) {

                    if (!actionMenu.opened) {
                        gridView.currentIndex = -1;
                    }

                    pressX = -1;
                    pressY = -1;
                    lastX = -1;
                    lastY = -1;
                    pressedItem = null;
                }
            }
        }
    }
}
