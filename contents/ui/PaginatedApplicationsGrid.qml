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

    property int pageCount
    readonly property int currentIndex: appsSwipeview.currentIndex
    readonly property int numberOfColumns: Math.floor(parent.width / cellSize)
    readonly property int numberOfRows: Math.floor(parent.height / cellSize)

    id: artifactForProperlyDisplayingEverythingInANiceWay

    anchors.fill: parent

    onWidthChanged: {
        resetAppsGrid()
    }

    onHeightChanged: {
        resetAppsGrid()
    }

    function calculateNumberOfPages(categoryIndex, isFavoritePage) { // TODO - number of pages is only corrected after searching or changing category.
        if ((categoryIndex != rootModel.showRecentApps + rootModel.showRecentDocs) || isFavoritePage) { // only calculate pages when we are in the "All Applications" category. Else, rootModel defaults to just using a page for some reason.
            pageCount = 1//HACK
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

    }


    function resetAppsGrid() {

        rootModel.pageSize = numberOfColumns * numberOfRows
        appsSwipeview.interactive = true

        if(plasmoid.configuration.startOnFavorites)
            changeCategory(-1) // start on "Favorites" category
        else
            changeCategory(rootModel.showRecentApps + rootModel.showRecentDocs)
        highlightItemAt(0,0) // preemptively focus first item
    }

    function changeCategory(indexInModel) { // this function receives the "change category!" order from the category buttons and translates the index from said button into an order the paginated applications grid can understand.
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

        calculateNumberOfPages(categoryIndexToDoStuffWith, isCategoryFavorites)
        appsGridPagesRepeater.model = pageCount
        appsSwipeview.updateGridModel(categoryIndexToDoStuffWith, isCategoryFavorites)
    }

    // Functions to call from our search bar to manage this grid.
    function showSearchResults() {
        calculateNumberOfPages(-1, false)
        appsGridPagesRepeater.model = pageCount
        appsSwipeview.changeToSearchModel()
        appsSwipeview.interactive = false
    }

    function updateQuery(text) {
        runnerModel.query = text
    }

    function highlightItemAt(row, column) {
        appsSwipeview.tryActivateItemAt(row, column)
    }

    SwipeView {

        id: appsSwipeview

        signal updateGridModel(int myCategoryIndex, bool isFavorite)
        signal changeToSearchModel()
        signal tryActivateItemAt(int row, int column)

        anchors.fill: parent
        clip: true

        Repeater {

            id: appsGridPagesRepeater
            model: pageCount
            ItemGridView {

                id: appsGridPage
                cellWidth:  cellSize
                cellHeight: cellSize

                onKeyNavUp: {
                    currentIndex = -1
                    searchField.focus = true
                }

                onKeyNavRight: {
                    if ((index == appsSwipeview.currentIndex) && (appsSwipeview.currentIndex < appsSwipeview.count - 1)) { // there are more items on our right
                        var rowToHighlight = currentRow()
                        appsSwipeview.incrementCurrentIndex()
                        appsSwipeview.tryActivateItemAt(rowToHighlight, 0) // highlight item at the corresponding row of the first column
                    }
                }

                onKeyNavLeft: {
                    if ((index == appsSwipeview.currentIndex) && (appsSwipeview.currentIndex > 0)) { // there are more items on our left
                        var rowToHighlight = currentRow()
                        appsSwipeview.decrementCurrentIndex()
                        appsSwipeview.tryActivateItemAt(rowToHighlight, numberOfColumns - 1)
                    }
                }

                Connections {
                    target: appsSwipeview
                    onUpdateGridModel: {

                        if (myCategoryIndex == rootModel.showRecentApps + rootModel.showRecentDocs)  // we are either going to show favorites or all apps
                            if (isFavorite)
                                appsGridPage.model = rootModel.modelForRow(myCategoryIndex).modelForRow(0)
                            else
                                appsGridPage.model = rootModel.modelForRow(myCategoryIndex).modelForRow(index + 1)// shift first "All applications" index to account for the "Favorites" category
                        else if (myCategoryIndex <= rootModel.showRecentApps + rootModel.showRecentDocs) // show either recent docs or recent apps
                            appsGridPage.model = rootModel.modelForRow(myCategoryIndex)
                        else // show a generic category
                            appsGridPage.model = rootModel.modelForRow(myCategoryIndex).modelForRow(index)

                    }
                    onChangeToSearchModel: {
                        appsGridPage.model = runnerModel.modelForRow(0)
                    }

                    onTryActivateItemAt: { // highlight item at coordinates (row, column) in the visible grid
                        if (appsSwipeview.currentIndex == index)
                            appsGridPage.tryActivate(row, column)
                            
                    }
                }
            }
        }

    }


    //}



}
