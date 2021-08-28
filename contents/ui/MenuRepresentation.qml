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
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.private.kicker 0.1 as Kicker

import "../code/tools.js" as Tools
import QtQuick.Window 2.0
import QtQuick.Controls.Styles 1.4

import org.kde.kcoreaddons 1.0 as KCoreAddons

Kicker.DashboardWindow {
    
    id: root

//     property bool smallScreen: ((Math.floor(width / PlasmaCore.Units.iconSizes.huge) <= 22) || (Math.floor(height / PlasmaCore.Units.iconSizes.huge) <= 14))

//     property int iconSize: smallScreen ? PlasmaCore.Units.iconSizes.large : PlasmaCore.Units.iconSizes.huge

    //property int iconSize:    PlasmaCore.Units.iconSizes.enormous //
    property int iconSize:    plasmoid.configuration.iconSize // if iconSize == 48 then the icons' size will be 48x48. Enormous will make them look decent (in my screen, that is! :-) )

    //property int iconSize: PlasmaCore.Units.iconSizes.enormous
//     property int iconSize: Math.floor(1.5 * PlasmaCore.Units.iconSizes.huge)

    property int cellSize: iconSize + Math.floor(1.5 * PlasmaCore.Theme.mSize(PlasmaCore.Theme.defaultFont).height)
        + (2 * PlasmaCore.Units.smallSpacing)
        + (2 * Math.max(highlightItemSvg.margins.top + highlightItemSvg.margins.bottom,
                        highlightItemSvg.margins.left + highlightItemSvg.margins.right))

    keyEventProxy: searchField // Set "searchField" as our keybord input receiver

    backgroundColor: "transparent"

    property int columns: Math.floor(0.8 * Math.ceil(width / cellSize))
    property int rows: Math.floor(0.75 * Math.ceil(height / cellSize))

    property int widthScreen:  columns * cellSize
    property int heightScreen: rows    * cellSize

    property bool searching: searchField.text != ""

    function colorWithAlpha(color, alpha) {
        return Qt.rgba(color.r, color.g, color.b, alpha)
    }

    onKeyEscapePressed: {
        root.toggle()
    }

    onVisibleChanged: {
        animationSearch.start()
        reset();
    }

    onSearchingChanged: {
        //console.log("searching: ", searching)
    }

    function reset() {
            //appsGrid.model = rootModel.systemFavorites;
        appsGrid.model = rootModel.modelForRow(0).modelForRow(1)
        appsGrid.focus = true
        appsGrid.currentIndex = 0;
        searchField.text = ""
    }


    //mainItem:
        Rectangle{

            anchors.fill: parent
            color: 'transparent'
/*
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
            }*/

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
                    if (appsGrid.currentItem) {
                        appsGrid.currentItem.itemGrid.currentIndex = -1;
                    }
                }
            }


            KCoreAddons.KUser {
                id: kuser
            }

            PlasmaComponents.TextField {
                id: searchField

                anchors {
                    top: parent.top
                    topMargin: units.iconSizes.large
                    horizontalCenter: parent.horizontalCenter
                }

                font.pointSize: 20
                placeholderText: "What will you do today, " + kuser.loginName + "?"

                placeholderTextColor: colorWithAlpha(PlasmaCore.Theme.headerTextColor, 0.8)

                background: Rectangle {
                        color: "transparent"
                }

            }

            Rectangle { // applications will be inside this
                width: widthScreen
//                 height: heightScreen
                color: "transparent" // use "red" to see real dimensions and limits
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: searchField.bottom
                    topMargin: units.iconSizes.medium
                    bottom: sessionControlBar.top
                    bottomMargin: units.iconSizes.medium
                }

                ItemGridView { // no model needed to set in this block of code - it's set somewhere else
                    id: appsGrid
                    visible: model.count > 0
                    anchors.fill: parent
                    cellWidth:  cellSize
                    cellHeight: cellSize

                    verticalScrollBarPolicy: Qt.ScrollBarAlwaysOff

                    model:  rootModel.modelForRow(0).modelForRow(1)

                    //model: globalFavorites // equivalent
                    //model: rootModel.systemFavorites // equivalent



                    //onCurrentIndexChanged: {
                        //if (currentIndex != -1 && !searching) {
                            //appsGridScrollArea.focus = true;
                            //focus = true;
                        //}
                    //}

                    //onCountChanged: {
                        //if (searching && currentIndex == 0) {
                            //currentIndex = 0;
                        //}
                    //}
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

                height: cellHeight
                width: systemFavorites.count * cellWidth

                model: systemFavorites

//                 usesPlasmaTheme: true // for using Plasma Style icons should you want inconsistency

                anchors {
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                }
            }

            Keys.onPressed: {
                if (event.key == Qt.Key_Escape) {
                    event.accepted = true;
                    console.log("HOLA")
                    if (searching) {
                        searchField.text = ""
                    } else {
                        root.toggle();
                    }
                }
            }

            //Keys.onPressed: {
                //if (event.key == Qt.Key_Escape) {
                    //event.accepted = true;

                    //if (searching) {
                        //reset();
                    //} else {
                        //root.toggle();
                    //}

                    //root.toggle()
                    //return;
                //}

                //if (searchField.focus) {
                    //return;
                //}

                //if (event.key == Qt.Key_Backspace) {
                    //event.accepted = true;
                    //searchField.backspace();
                //} else if (event.key == Qt.Key_Tab || event.key == Qt.Key_Backtab) {
                    //if (appsGridScrollArea.focus == true && appsGrid.currentItem.itemGrid.currentIndex == -1) {
                        //event.accepted = true;
                        //appsGrid.currentItem.itemGrid.tryActivate(0, 0);
                    //}
                //} else if (event.text != "") {
                    //event.accepted = true;
                    //searchField.appendText(event.text);
                //}
            //}


        }

    }
    Component.onCompleted: {
        rootModel.pageSize = -1 // this will, somehow, make it show everything -- again, don't ask me!
//         appsGrid.model = rootModel.modelForRow(0).modelForRow(1);
        //appsGridScrollArea.focus = true;
        //appsGrid.currentIndex = 1; // doesn't do much
        kicker.reset.connect(reset);
    }
}
