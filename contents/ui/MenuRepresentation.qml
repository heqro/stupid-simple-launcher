/***************************************************************************
 *   Copyright (C) 2014 by Weng Xuetian <wengxt@gmail.com>
 *   Copyright (C) 2013-2017 by Eike Hein <hein@kde.org>                   *
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
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.private.kicker 0.1 as Kicker

import "../code/tools.js" as Tools
import QtQuick.Window 2.0
import QtQuick.Controls.Styles 1.4


Kicker.DashboardWindow {
    
    id: root

    property bool smallScreen: ((Math.floor(width / PlasmaCore.Units.iconSizes.huge) <= 22) || (Math.floor(height / PlasmaCore.Units.iconSizes.huge) <= 14))

//     property int iconSize: smallScreen ? PlasmaCore.Units.iconSizes.large : PlasmaCore.Units.iconSizes.huge

    property int iconSize:    plasmoid.configuration.iconSize // if iconSize == 48 then the icons' size will be 48x48

    //property int iconSize: PlasmaCore.Units.iconSizes.enormous
//     property int iconSize: Math.floor(1.5 * PlasmaCore.Units.iconSizes.huge)

    property int cellSize: iconSize + Math.floor(1.5 * PlasmaCore.Theme.mSize(PlasmaCore.Theme.defaultFont).height)
        + (2 * PlasmaCore.Units.smallSpacing)
        + (2 * Math.max(highlightItemSvg.margins.top + highlightItemSvg.margins.bottom,
                        highlightItemSvg.margins.left + highlightItemSvg.margins.right))


    property bool searching: (searchField.text != "")

    keyEventProxy: searchField
    backgroundColor: "transparent"

    property bool linkUseCustomSizeGrid: plasmoid.configuration.useCustomSizeGrid

    property int columns: Math.floor(0.8 * Math.ceil(width / cellSize))
    property int rows: Math.floor(0.75 * Math.ceil(height / cellSize))


    property int widthScreen:  columns * cellSize
    property int heightScreen: rows    * cellSize

    function colorWithAlpha(color, alpha) {
        return Qt.rgba(color.r, color.g, color.b, alpha)
    }

    onKeyEscapePressed: {
        if (searching) {
            searchField.text = ""
        } else {
            root.toggle();
        }
    }

    onVisibleChanged: {
        animationSearch.start()

        reset();
        rootModel.pageSize = rows * columns
        pageList.currentIndex = 1;
    }

    onSearchingChanged: {
        if (searching) {
            pageList.model = runnerModel;
            paginationBar.model = runnerModel;
        } else {
            reset();
        }
    }

    function reset() {
        if (!searching) {
            pageList.model = rootModel.modelForRow(0);
            paginationBar.model = rootModel.modelForRow(0);
        }
        searchField.text = "";
        pageListScrollArea.focus = true;
        pageList.currentIndex = 1;
    }


    mainItem:
        Rectangle{

            anchors.fill: parent
            color: 'transparent'

            Image {
                source: "br.png"
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                z:2
            }
            Image {
                source: "bl.png"
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                z:2
            }
            Image {
                source: "tr.png"
                anchors.right: parent.right
                anchors.top: parent.top
                z:2
            }
            Image {
                source: "tl.png"
                anchors.left: parent.left
                anchors.top: parent.top
                z:2
            }

        MouseArea {

            id: mainItemRoot
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            LayoutMirroring.enabled: Qt.application.layoutDirection == Qt.RightToLeft
            LayoutMirroring.childrenInherit: true
            focus: true

            ScaleAnimator{
                id: animationSearch
                from: 1.1
                to: 1
                target: mainItemRoot
            }

            onClicked: {
                root.toggle();
            }

            Rectangle{
                anchors.fill: parent
                color: colorWithAlpha(theme.backgroundColor,0.6)
            }

            PlasmaExtras.Heading {
                id: dummyHeading
                visible: false
                width: 0
                level: 5
            }

            TextMetrics {
                id: headingMetrics
                font: dummyHeading.font
            }

            ActionMenu {
                id: actionMenu
                onActionClicked: visualParent.actionTriggered(actionId, actionArgument)
                onClosed: {
                    if (pageList.currentItem) {
                        pageList.currentItem.itemGrid.currentIndex = -1;
                    }
                }
            }

            //Rectangle{
                //anchors.horizontalCenter: searchField.horizontalCenter
                //y: searchField.y + searchField.height
                //width: searchField.width * 0.8
                //height: 1
                //border.width: 1
                //border.color: theme.highlightColor//theme.textColor
                //color: "transparent" // "red" to debug
                //radius: searchField.height*0.5
                //z: 2
            //}

            PlasmaComponents.TextField { // searchbar
                id: searchField
                z: 1
                anchors.top: parent.top
                anchors.topMargin: units.iconSizes.large

                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.2
                //font.pointSize: 14// units.largeSpacing // fixme: QTBUG font size in plasmaComponent3
                font.pointSize: units.gridUnit * 0.6
                //placeholderText: "<font color='"+colorWithAlpha(theme.textColor,0.7) +"'>Type to search...</font>"
                placeholderText: "Type to search..."
                horizontalAlignment: TextInput.AlignHCenter
                onTextChanged: {
                    runnerModel.query = text;
                }

                style: TextFieldStyle {
                    textColor: theme.textColor
                    background: Rectangle {
                        radius: height*0.5
                        color: theme.textColor
                        opacity: 0.2
                    }
                }
                Keys.onPressed: {
                    if (event.key == Qt.Key_Down) {
                        event.accepted = true;
                        pageList.currentItem.itemGrid.tryActivate(0, 0);
                    } else if (event.key == Qt.Key_Right) {
                        if (cursorPosition == length) {
                            event.accepted = true;

                            if (pageList.currentItem.itemGrid.currentIndex == -1) {
                                pageList.currentItem.itemGrid.tryActivate(0, 0);
                            } else {
                                pageList.currentItem.itemGrid.tryActivate(0, 1);
                            }
                        }
                    } else if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter) {
                        if (text != "" && pageList.currentItem.itemGrid.count > 0) {
                            event.accepted = true;
                            pageList.currentItem.itemGrid.tryActivate(0, 0);
                            pageList.currentItem.itemGrid.model.trigger(0, "", null);
                            root.toggle();
                        }
                    } else if (event.key == Qt.Key_Tab) {
                        event.accepted = true;
                        //systemFavoritesGrid.tryActivate(0, 0);
                    } else if (event.key == Qt.Key_Backtab) {
                        event.accepted = true;

                        if (!searching) {
                            pageList.currentIndex = 1;
                            filterList.forceActiveFocus();
                        } else {
                            //systemFavoritesGrid.tryActivate(0, 0);
                        }
                    }
                }

                function backspace() {
                    if (!root.visible) {
                        return;
                    }
                    focus = true;
                    text = text.slice(0, -1);

                }

                function appendText(newText) {
                    if (!root.visible) {
                        return;
                    }
                    focus = true;
                    text = text + newText;
                }
            }

            PlasmaCore.IconItem { // searchbar icon
                id: nepomunk
                source: "nepomuk"
                visible: !searchField.focus && searchField.text == "" // TODO: find a more elegant way to avoid nepomuk overlapping our query
                width:  searchField.height - 2
                height: width
                anchors {
                    left: searchField.left
                    leftMargin: 10
                    verticalCenter: searchField.verticalCenter
                }

            }


            Rectangle { // applications will be inside this
                width:   widthScreen
//                 height:  heightScreen // mess up with this
                color: "transparent" // use "red" to see real dimensions and limits
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: nepomunk.bottom
                    topMargin: units.iconSizes.medium
                    bottom: sessionControlBar.top
//                     bottomMargin: units.iconSizes.medium
                }

                PlasmaExtras.ScrollArea { // structure for storing applications
                    id: pageListScrollArea
                    anchors.fill: parent
                    focus: true;
                    frameVisible: false; // debugging area -> set to true
                    horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
                    verticalScrollBarPolicy: Qt.ScrollBarAlwaysOff

                    ListView {
                        id: pageList
                        anchors.fill: parent

                        snapMode: ListView.SnapOneItem
                        orientation: Qt.Horizontal

                        onCurrentIndexChanged: {
                            positionViewAtIndex(currentIndex, ListView.Contain);
                        }
                        onCurrentItemChanged: {
                            if (!currentItem) {
                                return;
                            }
                            currentItem.itemGrid.focus = true;
                        }
                        onModelChanged: {
                            if(searching)  {
                                currentIndex = 0;
                            }
                            else{
                                currentIndex = 1;
                            }
                        }
                        onFlickingChanged: {
                            if (!flicking) {
                                var pos = mapToItem(contentItem, root.width / 2, root.height / 2);
                                var itemIndex = indexAt(pos.x, pos.y);
                                currentIndex = itemIndex;
                            }
                        }

                        function cycle() {
                            enabled = false;
                            enabled = true;
                        }

                        function activateNextPrev(next) { // determines whether or not we want to go to the next page or the previous one
                            if (next) {
                                var newIndex = pageList.currentIndex + 1;

                                if (newIndex < pageList.count) {
                                    pageList.currentIndex = newIndex;
                                }

                            } else {
                                var newIndex = pageList.currentIndex - 1;

                                if (newIndex >= 1) {
                                    pageList.currentIndex = newIndex;
                                }

                            }
                        }

                        delegate: Item {

                            width:   columns * cellSize
                            height:  rows * cellSize

                            property Item itemGrid: gridView

                            ItemGridView { // defined in ItemGridView.qml
                                id: gridView

                                visible: model.count > 0
                                anchors.fill: parent

                                cellWidth:  cellSize
                                cellHeight: cellSize

                                horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
                                verticalScrollBarPolicy: Qt.ScrollBarAlwaysOff

                                dragEnabled: (index == 0)

                                model: searching ? runnerModel.modelForRow(index) : rootModel.modelForRow(0).modelForRow(index)
                                onCurrentIndexChanged: {
                                    if (currentIndex != -1 && !searching) {
                                        pageListScrollArea.focus = true;
                                        focus = true;
                                    }
                                    //if(!visible && (currentIndex + 1) < pageList.count ){
                                    //    currentIndex = currentIndex + 1
                                    //}
                                }

                                onCountChanged: {
                                    if (searching && index == 0) {
                                        currentIndex = 0;
                                    }
                                }

                                //signal handlers emitted from ItemGridView.qml

                                onKeyNavUp: {
                                    currentIndex = -1;
                                    searchField.focus = true;
                                }

                                onKeyNavDown: {

                                }
                                onKeyNavRight: {
                                    var newIndex = pageList.currentIndex + 1;
                                    if (newIndex < pageList.count) {
                                        pageList.currentIndex = newIndex;
                                        pageList.currentItem.itemGrid.tryActivate(0, 0);
                                    }
                                }

                                onKeyNavLeft: {
                                    var newIndex = pageList.currentIndex - 1;
                                    if (newIndex > 0) {
                                        pageList.currentIndex = newIndex;
                                        pageList.currentItem.itemGrid.tryActivate(0, 0);
                                    }
                                }
                            }

                            Kicker.WheelInterceptor {
                                anchors.fill: parent
                                z: 1

                                property int wheelDelta: 0

                                function scrollByWheel(wheelDelta, eventDelta) {
                                    // magic number 120 for common "one click"
                                    // See: http://qt-project.org/doc/qt-5/qml-qtquick-wheelevent.html#angleDelta-prop
                                    wheelDelta += eventDelta;

                                    var increment = 0;

                                    while (wheelDelta >= 120) {
                                        wheelDelta -= 120;
                                        increment++;
                                    }

                                    while (wheelDelta <= -120) {
                                        wheelDelta += 120;
                                        increment--;
                                    }

                                    while (increment != 0) {
                                        pageList.activateNextPrev(increment < 0);
                                        increment += (increment < 0) ? 1 : -1;
                                    }

                                    return wheelDelta;
                                }

                                onWheelMoved: {
                                    // determine predominant direction should you have a touchpad
                                    var predominantDelta = (Math.abs(delta.x) > Math.abs(delta.y)) ? delta.x : delta.y
                                    wheelDelta = scrollByWheel(wheelDelta, predominantDelta)

                                    // debugging
                                    //console.log("El valor de PlasmaCore.Theme.mSize(PlasmaCore.Theme.defaultFont).height es ", PlasmaCore.Theme.mSize(PlasmaCore.Theme.defaultFont).height)
//                                     console.log("cellsize is ", cellSize)
//                                     console.log("cellsizew is ", cellSizeWidth)
//                                     console.log("cellsizeh is ", cellSizeHeight)
//                                     console.log("number of columns is ", columns)
//                                     console.log("number of rows is ", rows)
                                }
                            }
                        }
                    }
                }

            }

            ItemGridView { // shutdown, reboot, logout, lock
                id: sessionControlBar
                showLabels: false

//                 cellWidth: Math.floor(cellSize   * 6 / 7)
                //PlasmaCore.Units.iconSizes.enormous
                //cellHeight: cellSize
//                 cellHeight: Math.floor(cellSize * 6 / 7)


                iconSize:   PlasmaCore.Units.iconSizes.large
                cellHeight: iconSize + (2 * PlasmaCore.Units.smallSpacing) + (2 * Math.max(highlightItemSvg.margins.top + highlightItemSvg.margins.bottom, highlightItemSvg.margins.left + highlightItemSvg.margins.right))
                cellWidth: iconSize + (2 * PlasmaCore.Units.smallSpacing) + (2 * Math.max(highlightItemSvg.margins.top + highlightItemSvg.margins.bottom, highlightItemSvg.margins.left + highlightItemSvg.margins.right))
                //cellHeight: iconSize + PlasmaCore.Theme.mSize(PlasmaCore.Theme.defaultFont).height+ (2 * PlasmaCore.Units.smallSpacing) + (2 * Math.max(highlightItemSvg.margins.top + highlightItemSvg.margins.bottom, highlightItemSvg.margins.left + highlightItemSvg.margins.right))

//                 height: cellHeight


                //cellWidth: iconSize + PlasmaCore.Theme.mSize(PlasmaCore.Theme.defaultFont).height + (2 * PlasmaCore.Units.smallSpacing) + (2 * Math.max(highlightItemSvg.margins.top + highlightItemSvg.margins.bottom, highlightItemSvg.margins.left + highlightItemSvg.margins.right))

                height: cellHeight
                width: systemFavorites.count * cellWidth

                model: systemFavorites

//                 usesPlasmaTheme: true // for using Plasma Style icons should you want inconsistency

                anchors {
                    bottom: parent.bottom
//                     top: pageListScrollArea.bottom
                    //bottomMargin: PlasmaCore.Units.iconSizes.small
                    horizontalCenter: parent.horizontalCenter
                }
            }

            ListView { // buttons to select your page lie here
                id: paginationBar

                anchors {
                    //bottom: parent.bottom
                    right: parent.right
                    //rightMargin: units.iconSizes.medium
                    verticalCenter: parent.verticalCenter
                }
                width: model.count * units.iconSizes.huge
                height:  units.largeSpacing

                orientation: Qt.Horizontal
                rotation: 90 // for some reason I cannot use Qt.Vertical

                delegate: Item {
                    width: units.iconSizes.medium
                    height: width

                    Rectangle {
                        id: pageDelegate
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            verticalCenter: parent.verticalCenter
                            margins: 10
                        }
                        width: parent.width * 0.5
                        height: width

                        property bool isCurrent: (pageList.currentIndex == index)

                        radius: width / 2
                        color: theme.textColor
                        visible: (index != 0) // favorites section is hidden
                        opacity: 0.5
                        Behavior on width { SmoothedAnimation { duration: units.longDuration; velocity: 0.005 } }
                        Behavior on opacity { SmoothedAnimation { duration: units.longDuration; velocity: 0.005 } }

                        states: [
                            State {
                                when: pageDelegate.isCurrent
                                PropertyChanges { target: pageDelegate; width: 0.75 * parent.width }
                                PropertyChanges { target: pageDelegate; opacity: 1 }
                            }
                        ]
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (index != 0) {
                                // avoid hidden favorites from being selected (TODO - this should be done in a much more elegant fashion from configuration)
                                pageList.currentIndex = index;
                            }
                        }

                        property int wheelDelta: 0

                        function scrollByWheel(wheelDelta, eventDelta) {
                            // magic number 120 for common "one click"
                            // See: http://qt-project.org/doc/qt-5/qml-qtquick-wheelevent.html#angleDelta-prop
                            wheelDelta += eventDelta;

                            var increment = 0;

                            while (wheelDelta >= 120) {
                                wheelDelta -= 120;
                                increment++;
                            }

                            while (wheelDelta <= -120) {
                                wheelDelta += 120;
                                increment--;
                            }

                            while (increment != 0) {
                                pageList.activateNextPrev(increment < 0);
                                increment += (increment < 0) ? 1 : -1;
                            }

                            return wheelDelta;
                        }

                        onWheel: {
                            wheelDelta = scrollByWheel(wheelDelta, wheel.angleDelta.y);
                        }
                    }
                }
            }

            Keys.onPressed: {
                if (event.key == Qt.Key_Escape) {
                    event.accepted = true;

                    if (searching) {
                        reset();
                    } else {
                        root.toggle();
                    }

                    return;
                }

                if (searchField.focus) {
                    return;
                }

                if (event.key == Qt.Key_Backspace) {
                    event.accepted = true;
                    searchField.backspace();
                } else if (event.key == Qt.Key_Tab || event.key == Qt.Key_Backtab) {
                    if (pageListScrollArea.focus == true && pageList.currentItem.itemGrid.currentIndex == -1) {
                        event.accepted = true;
                        pageList.currentItem.itemGrid.tryActivate(0, 0);
                    }
                } else if (event.text != "") {
                    event.accepted = true;
                    searchField.appendText(event.text);
                }
            }


        }

    }
    Component.onCompleted: {
        rootModel.pageSize = columns*rows
        pageList.model = rootModel.modelForRow(0);
        paginationBar.model = rootModel.modelForRow(0);
        searchField.text = "";
        pageListScrollArea.focus = true;
        pageList.currentIndex = 1;
        kicker.reset.connect(reset);
        
    }
}
