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

    property int allAppsCount
    property int pageCount
    readonly property int currentIndex: appsSwipeview.currentIndex


    id: artifactForProperlyDisplayingEverythingInANiceWay
    Layout.fillWidth: true
    Layout.fillHeight: true

    onWidthChanged: {
        resetAppsGrid()
    }

    onHeightChanged: {
        resetAppsGrid()
    }

    function calculateNumberOfPages(categoryIndex, isFavoritePage) {
        if ((categoryIndex != rootModel.showRecentApps + rootModel.showRecentDocs) || isFavoritePage) { // only calculate pages when we are in the "All Applications" category. Else, rootModel defaults to just using a page for some reason.
            pageCount = 1
            return
        }

        while (1) {
            if(rootModel.modelForRow(categoryIndex).modelForRow(pageCount))
                pageCount++
            else
                break
        }
        pageCount-- // There is an extra page in the "All Applications" category dedicated to the "Favorites" category. We account for that decreasing the index by an unit.
        appsSwipeview.interactive = true
        console.log("calculateNumberOfPages(",categoryIndex,") returns",pageCount)
    }


    function resetAppsGrid() {
//         appsGrid.focus = true
        var w_Aux = Math.floor(width / cellSize)
        var h_Aux = Math.floor(height / cellSize)
        rootModel.pageSize = w_Aux * h_Aux
        appsSwipeview.interactive = true

        if(plasmoid.configuration.startOnFavorites)
            changeCategory(-1) // start on "Favorites" category
        else
            changeCategory(rootModel.showRecentApps + rootModel.showRecentDocs) // TODO - swap this for the Favorites category should the user choose to start the menu off it.
    }

    function changeCategory(indexInModel) {
        var categoryIndexToDoStuffWith
        var isCategoryFavorites = false
        switch (indexInModel) {

            case -1: { // Favorites are hard-tagged as index -1
                categoryIndexToDoStuffWith = rootModel.showRecentApps + rootModel.showRecentDocs
                isCategoryFavorites = true
                break
            }
            case -2: { // Recent documents are hard-tagged as index -2
                categoryIndexToDoStuffWith = rootModel.showRecentApps
                break
            }
            case -3: { // Recent Applications are hard-tagged as index -3
                categoryIndexToDoStuffWith = !rootModel.showRecentApps
                break
            }
            default: { // Generic category or All applications
                categoryIndexToDoStuffWith = indexInModel
            }
        }

        //TODO - -2 -3 no funciona
        calculateNumberOfPages(categoryIndexToDoStuffWith, isCategoryFavorites)
        appsGridPagesRepeater.model = pageCount
        appsSwipeview.updateCoso(categoryIndexToDoStuffWith, isCategoryFavorites)
    }

    // Functions to call from our search bar to manage this grid.
    function showSearchResults() {
        //appsGridPagesRepeater.model = 1 // create a dedicated page for showing the search results
        appsSwipeview.interactive = false
        appsSwipeview.changeToSearchModel()
    }

    function updateQuery(text) {
        runnerModel.query = text
    }

    function highlightItemAt(row, column) {
//         if (myFavorites.visible)
//             myFavorites.tryActivate(row, column)
//         else

            //appsGrid.tryActivate(row, column)
    }

        SwipeView {

            id: appsSwipeview

            signal updateCoso(int myCategoryIndex, bool isFavorite)
            signal changeToSearchModel()

            anchors.fill: parent
            clip: true

            Repeater {

                id: appsGridPagesRepeater
                model: pageCount
                ItemGridView {
                    id: appsGridPage
                    cellWidth:  cellSize
                    cellHeight: cellSize
                    //onKeyNavUp: {
                        //console.log("MODEL COUNT",model.count)
                        //currentIndex = -1;
                        //if (showFavoritesInGrid && !searching) {
                            //myFavorites.tryActivate(0,0)
                        //} else {
                            //searchField.focus = true;
                        //}
                    //}

                    Connections {
                        target: appsSwipeview
                        onUpdateCoso: {

                            if (myCategoryIndex == rootModel.showRecentApps + rootModel.showRecentDocs && !isFavorite) // shift first "All applications" index to account for the "Favorites" category
                                appsGridPage.model = rootModel.modelForRow(myCategoryIndex).modelForRow(index + 1)
                            else
                                appsGridPage.model = rootModel.modelForRow(myCategoryIndex).modelForRow(index)

                        }
                        onChangeToSearchModel: {
                            appsGridPage.model = runnerModel.modelForRow(0)
                        }
                    }
                    //Rectangle {
                        //anchors.fill: parent
                        //color: "transparent"
                        //border.color: colorWithAlpha(theme.buttonFocusColor, 1)
                        //border.width: Math.floor(units.smallSpacing/4)
                        //radius: 40
                    //}
                }
            }

        }


    //}



}
