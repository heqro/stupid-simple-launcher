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

    property int iconSize:    plasmoid.configuration.iconSize // if iconSize == 48 then the icons' size will be 48x48. Enormous will make them look decent (in my screen, that is! :-) )

    property int cellSize: iconSize + Math.floor(1.5 * PlasmaCore.Theme.mSize(PlasmaCore.Theme.defaultFont).height)
        + (2 * PlasmaCore.Units.smallSpacing)
        + (2 * Math.max(highlightItemSvg.margins.top + highlightItemSvg.margins.bottom,
                        highlightItemSvg.margins.left + highlightItemSvg.margins.right))

    backgroundColor: "transparent"

    keyEventProxy: searchField


    property int columns: Math.floor(0.8 * Math.ceil(width / cellSize))
    property int rows: Math.floor(0.75 * Math.ceil(height / cellSize))

    property int widthScreen:  columns * cellSize
    property int heightScreen: rows    * cellSize

    property bool searching: searchField.text != ""

    property bool showFavoritesInGrid: plasmoid.configuration.favoritesInGrid && globalFavorites.count > 0



    function colorWithAlpha(color, alpha) {
        return Qt.rgba(color.r, color.g, color.b, alpha)
    }

    onKeyEscapePressed: {
        if (searching) {
            searchField.text = ""
//             console.log("showFavoritesInGrid: ", showFavoritesInGrid)
        } else {
            root.toggle()
        }
    }

    onSearchingChanged: {
        if (searching) {
            pageList.model = runnerModel;
            //paginationBar.model = runnerModel;
        } else {
            reset();
        }

    }

    onVisibleChanged: {
        animationSearch.start()
        reset();
    }

    function reset() {
        if (!searching) {
            pageList.model = rootModel.modelForRow(0).modelForRow(1)
        }
        //pageListScrollArea.focus = true

//         appsGrid.currentIndex = 0
        //pageList.currentIndex = 0;
        pageList.focus = true
        searchField.text = ""
    }

    mainItem:
        Rectangle {

            anchors.fill: parent
            color: 'transparent'

            MouseArea {

                id: mainItemRoot
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                LayoutMirroring.enabled: Qt.application.layoutDirection == Qt.RightToLeft
                LayoutMirroring.childrenInherit: true
//                 focus: true

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




                KCoreAddons.KUser {
                    id: kuser
                }

                PlasmaComponents.TextField { //searchbar
                    id: searchField

                    anchors {
                        top: parent.top
                        topMargin: units.iconSizes.large
                        horizontalCenter: parent.horizontalCenter
                    }

                    property string greetingMessage: plasmoid.configuration.greetingText

                    font.pointSize: 20
                    placeholderText: plasmoid.configuration.greetingText.length > 0 ? plasmoid.configuration.greetingText : "Howdy, " + kuser.loginName + "! Type to start searching..."
                    placeholderTextColor: colorWithAlpha(PlasmaCore.Theme.headerTextColor, 0.8)
                    horizontalAlignment: TextInput.AlignHCenter

                    onTextChanged: {
                        runnerModel.query = text
                    }

                    background: Rectangle {
                        color: "transparent"
                    }

                    visible: true

                    Keys.onPressed: {
                        if (event.key == Qt.Key_Down) {
                            event.accepted = true;
                            pageList.currentIndex = 0 // "return to the grid"
                            if (!searching) {
                                if (!showFavoritesInGrid) {
                                    pageList.currentItem.itemGrid.tryActivate(0, 0); // highlight
                                } else {
                                    myFavorites.tryActivate(0,0) // highlight first entry of favoritesGrid
                                }
                            } else {
                                pageList.currentItem.itemGrid.tryActivate(1, 0); // highlight first item - second row
                            }
                        } else if (event.key == Qt.Key_Right) {
                            if (cursorPosition == length) {
                                event.accepted = true;
                                pageList.currentIndex = 0 // "return to the grid"
                                if (!searching) {
                                    if (!showFavoritesInGrid) {
                                        pageList.currentItem.itemGrid.tryActivate(0, 0); // highlight
                                    } else {
                                        myFavorites.tryActivate(0,0) // highlight first entry of favoritesGrid
                                    }
                                } else {
                                    pageList.currentItem.itemGrid.tryActivate(0, 1); // highlight second item - first row
                                }
                            }
                        } else if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter) {
                            pageList.currentIndex = 0 // "return to the grid"
                            if (text != "" && pageList.currentItem.itemGrid.count > 0) {
                                event.accepted = true;
                                //pageList.currentIndex = 0 // "return to the grid"
                                pageList.currentItem.itemGrid.tryActivate(0, 0);
                                pageList.currentItem.itemGrid.model.trigger(0, "", null);
                                root.toggle();
                            }
                        }
                    }
                    //enabled: false // this crashes plasmashell xdxd
                }

                Rectangle { // applications will be inside this
                    id: appsRectangle
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

                    ItemGridView {
                        id: myFavorites
                        model: globalFavorites
                        visible: showFavoritesInGrid && !searching
                        height: (showFavoritesInGrid && !searching) ? cellSize : 0
                        width: columns * cellSize
                        cellWidth:  cellSize
                        cellHeight: cellSize

                        onKeyNavDown: {
                            pageList.currentItem.itemGrid.tryActivate(0, 0); // highlight first entry of our "All Applications" grid
                        }

                        onKeyNavUp: {
                            searchField.focus = true;
                        }

                    }

                    PlasmaCore.SvgItem {
                        id: horizontalSeparator
//                         opacity: applicationsView.listView.contentY !== 0
                        visible: showFavoritesInGrid && !searching
                        height: (showFavoritesInGrid && !searching) ? PlasmaCore.Units.devicePixelRatio * 4 : 0
                        width: Math.round(widthScreen * 0.75)
                        elementId: "horizontal-line"
                        z: 1

                        anchors {
//                             left: parent.left
//                             leftMargin: PlasmaCore.Units.smallSpacing * 4
//                             right: parent.right
//                             rightMargin: PlasmaCore.Units.smallSpacing * 4
                            horizontalCenter: parent.horizontalCenter
                            top: myFavorites.bottom
                            topMargin: (showFavoritesInGrid && !searching) ?units.iconSizes.smallMedium : undefined
                        }

                        Behavior on opacity {
                            NumberAnimation {
                                duration: PlasmaCore.Units.shortDuration
                                easing.type: Easing.InOutQuad
                            }
                        }

                        svg: PlasmaCore.Svg {
                            imagePath: "widgets/line"
                        }
                    }

                    ListView {
                        id: pageList
                        anchors.top: horizontalSeparator.bottom
                        anchors.topMargin: (showFavoritesInGrid && !searching) ?units.iconSizes.small : undefined// if favorites are shown, then it all will look beautiful. If they are not shown, the horizontal separator still exists, but will have null height and will be invisible. Therefore, it all will look beautiful as well.
                        interactive: false // this fixes a nasty occurrence by which we would have this ListView listed all over again after scrolling for a short while


//                         keyNavigationEnabled: true


//                             model: rootModel

                        //onCurrentIndexChanged: {
                            //positionViewAtIndex(currentIndex, ListView.Contain);
                        //}

                        onCurrentItemChanged: {
                            if (!currentItem) {
                                return;
                            }
//                             if (!searching) {
//                                 currentItem.itemGrid.focus = true;
//                             } else {
//
//                             }
                            currentItem.itemGrid.focus = true;
                        }
                        //onModelChanged: {
                            //currentIndex = 0
                            //currentItem.focus = false
                            //if (searching) {
                                //currentItem.itemGrid.focus = false;
                            //}
                            //console.log("Modelo cambiado")
                        //}

                        delegate: Item {
                            width: columns * cellSize
                            height: (!showFavoritesInGrid || searching) ? rows * cellSize : (rows - 1) * cellSize

                            property Item itemGrid: appsGrid
                            focus: true

                            ItemGridView {
                                id: appsGrid
                                visible: model.count > 0
                                anchors.fill: parent

                                cellWidth:  cellSize
                                cellHeight: cellSize

                                verticalScrollBarPolicy: Qt.ScrollBarAlwaysOff

                                dragEnabled: (index == 0)

                                model: searching ? runnerModel.modelForRow(0) : rootModel.modelForRow(0).modelForRow(1)

                                //onCountChanged: { // whenever the list of icons has its cardinality modified, account for the change
                                    //currentIndex = 0
                                    //itemGrid.tryActivate(0, 0);
                                //}

                                onKeyNavUp: {
                                    currentIndex = -1;
                                    if (showFavoritesInGrid && !searching) {
                                        myFavorites.tryActivate(0,0)
                                    } else {
                                        searchField.focus = true;
                                    }
                                }

                                // onKeyNavDown: { //TODO: this needs some work to communicate where to return if we are pressing the "up" key on sessionControlBar
                                    //currentIndex = -1
                                    //sessionControlBar.tryActivate(0,0)
                                //}

                                onModelChanged: {
                                    currentIndex = 0
                                    itemGrid.tryActivate(0, 0);
                                }
                            }
                        }
                    }
                }

                ItemGridView { // shutdown, reboot, logout, lock

                    id: sessionControlBar
                    showLabels: false // don't show the text under the options -- they are expressive enough if you pick almost any icon pack out there

                    iconSize:   PlasmaCore.Units.iconSizes.large
                    cellHeight: iconSize + (2 * PlasmaCore.Units.smallSpacing) + (2 * Math.max(highlightItemSvg.margins.top + highlightItemSvg.margins.bottom, highlightItemSvg.margins.left + highlightItemSvg.margins.right))
                    cellWidth: iconSize + (2 * PlasmaCore.Units.smallSpacing) + (2 * Math.max(highlightItemSvg.margins.top + highlightItemSvg.margins.bottom, highlightItemSvg.margins.left + highlightItemSvg.margins.right))

                    height: cellHeight
                    width: systemFavorites.count * cellWidth // extend it only as needed

                    model: systemFavorites // this model automatically feeds lock, shutdown, logout and reset options

    //                 usesPlasmaTheme: true // for using Plasma Style icons (I personally don't like them, so I just comment this and keep going)

                    anchors {
                        bottom: parent.bottom
                        horizontalCenter: parent.horizontalCenter
                    }

                    //onKeyNavUp { // communicating this grid with the applications grid will be tricky and may make the code unnecessarily trickier to understand

                    //}
                }
            }
        }


    Component.onCompleted: {
        rootModel.pageSize = -1 // this will, somehow, make it show everything -- again, don't ask me!
        kicker.reset.connect(reset);
    }
}
