import QtQuick 2.4

// for using RowLayout
import QtQuick.Layouts 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.components 3.0 as PlasmaComponents3

import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.private.kicker 0.1 as Kicker

import "../code/tools.js" as Tools
import QtQuick.Window 2.0
import QtQuick.Controls.Styles 1.4


// for vanilla scrollview
import QtQuick.Controls 2.2

Item {

    function resetAppsGrid() {
        rootModel.pageSize = -1
        appsGrid.focus = true
        if (startOnFavorites) {
            appsGrid.model = rootModel.modelForRow(rootModel.showRecentApps + rootModel.showRecentDocs).modelForRow(0)
        } else {
            appsGrid.model = rootModel.modelForRow(rootModel.showRecentApps + rootModel.showRecentDocs).modelForRow(1)
        }
    }

    function changeCategory(indexInModel) {
        switch (indexInModel) {
            case -1: { // Favorites are hard-tagged as index -1
                appsGrid.model = rootModel.modelForRow(rootModel.showRecentApps + rootModel.showRecentDocs).modelForRow(0)
                break
            }
            case -2: { // Recent documents are hard-tagged as index -2
                appsGrid.model = rootModel.modelForRow(rootModel.showRecentApps)
                break
            }
            case -3: { // Recent Applications are hard-tagged as index -3
                appsGrid.model = rootModel.modelForRow(!rootModel.showRecentApps)
                break
            }
            case rootModel.showRecentApps + rootModel.showRecentDocs: { // All Applications
                appsGrid.model = rootModel.modelForRow(rootModel.showRecentApps + rootModel.showRecentDocs).modelForRow(1)
                break
            }
            default: { // Show generic category
                appsGrid.model = rootModel.modelForRow(indexInModel).modelForRow(0)
            }
        }
    }

    // Functions to call from our search bar to manage this grid.
    function showSearchResults() {
        appsGrid.model = runnerModel.modelForRow(0)
    }

    function updateQuery(text) {
        runnerModel.query = text
    }

    function highlightItemAt(row, column) {
        if (myFavorites.visible)
            myFavorites.tryActivate(row, column)
        else
            appsGrid.tryActivate(row, column)
    }

    id: artifactForProperlyDisplayingEverythingInANiceWay
    anchors.fill: parent
    //Layout.fillWidth: true
    //Layout.fillHeight: true
    //Layout.bottomMargin: plasmoid.configuration.showSessionControlBar ? units.iconSizes.medium : units.iconSizes.large

    ColumnLayout {

        id: appsRectangle
        anchors.fill: parent

        ItemGridView { // this is the grid in which we will store the favorites list

            id: myFavorites
            model: globalFavorites
            visible: showFavoritesInGrid && !searching  // TODO this should be tied to whatever SearchBar is doing!!.
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumHeight: cellSize
            //                                     Layout.maximumWidth: rootWidth - categoriesItem.width
            //                                     height: (showFavoritesInGrid && !userIsSearching) ? cellSize : 0
            //width: columns * cellSize
            cellWidth:  cellSize
            cellHeight: cellSize

            onKeyNavDown: {
                appsGrid.tryActivate(0, 0); // highlight first entry of our "All Applications" grid
            }

            onKeyNavUp: {
                searchField.focus = true;
            }
        }

        PlasmaCore.SvgItem { // nice line to separate favorites between all applications
            id: horizontalSeparator
            visible: showFavoritesInGrid && !searching
            Layout.fillHeight: true
            Layout.maximumHeight: (showFavoritesInGrid && !searching) ? Math.floor(PlasmaCore.Units.devicePixelRatio * 4) : 0
            Layout.fillWidth: true
            Layout.maximumWidth: rootWidth - categoriesItem.width
            elementId: "horizontal-line"
            z: 1
            Layout.alignment: Qt.AlignCenter
            Layout.margins: units.iconSizes.smallMedium

            svg: PlasmaCore.Svg {
                imagePath: "widgets/line"
            }
        }


        ItemGridView { // this is actually the applications grid

            id: appsGrid
            visible: model.count > 0
            Layout.fillHeight: true
            Layout.fillWidth: true


            cellWidth:  cellSize
            cellHeight: cellSize

            //dragEnabled: (index == 0)

            model: searching ? runnerModel.modelForRow(0) : rootModel.modelForRow(0).modelForRow(1) // if we happen to be userIsSearching, then we must show the results of said search. Else, we will default to showing all the applications

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

            onModelChanged: { // when we stop userIsSearching or start userIsSearching, highlight the first item just to give the user a hint that pressing "Enter" will launch the first entry.
                currentIndex = 0
                //appsGrid.itemGrid.tryActivate(0, 0);
            }

            //onMenuUpdated: {
            //console.log("Aquí debería haber un mensajito de an application has been hidden o una animación para construir el modelo")
            //}
        }

    }
}
