import QtQuick 2.4

// for using RowLayout
import QtQuick.Layouts 1.1

import org.kde.plasma.plasmoid 2.0

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

    // Given that the dimensions of the apps grid is calculated right after the menu is launched (because that's how Layouts work), we have to communicate that the grid needs to be updated (if it needs to). The right way to do it -I believe- is to listen for whether or not the number of rows/columns of the app grid are to be updated. Thus, we save up calling this function too many times.
    onNumberOfRowsChanged: {
        rootModel.pageSize = numberOfColumns * numberOfRows // only communicate updated pageSize to avoid resetting the entire menu (not thoroughly tested, but less processor heavy nonethelesss)
    }
    onNumberOfColumnsChanged: {
        rootModel.pageSize = numberOfColumns * numberOfRows // only communicate updated pageSize to avoid resetting the entire menu (not thoroughly tested, but less processor heavy nonetheless)
    }

    function calculateNumberOfPages(categoryIndex, isFavoritePage) {
        pageCount = 1
        if (isFavoritePage || categoryIndex < allAppsIndex) { // the favorites category, as well as the recent files/apps, are set to have only one page as per the KDE's built-in model's design
            return pageCount
        }

        if (categoryIndex == allAppsIndex)
            pageCount = rootModel.modelForRow(categoryIndex).rowCount() - 1
        else
            pageCount = rootModel.modelForRow(categoryIndex).rowCount()

        appsSwipeview.interactive = true
        return pageCount

    }

    function resetAppsGrid() {

        rootModel.pageSize = numberOfColumns * numberOfRows
        appsSwipeview.interactive = true

        if(plasmoid.configuration.startOnFavorites)
            changeCategory(-1) // start on "Favorites" category
        else
            changeCategory(allAppsIndex)
        highlightItemAt(0,0) // preemptively focus first item
    }

    function changeCategory(appsGridModelKey) { // this function receives the "change category!" order from the category buttons and translates the index from said button into an order the paginated applications grid can understand.
        var categoryIndexToDoStuffWith
        var isCategoryFavorites = false
        switch (appsGridModelKey) {
            case -1: { // Favorites are hard-tagged as index -1
                categoryIndexToDoStuffWith = allAppsIndex
                isCategoryFavorites = true
                break
            }
            case -2: { // Recent documents are hard-tagged as index -2
                categoryIndexToDoStuffWith = 1
                break
            }
            case -3: { // Recent Applications are hard-tagged as index -3
                categoryIndexToDoStuffWith = 0
                break
            }
            default: { // Generic category or All applications
                categoryIndexToDoStuffWith = appsGridModelKey
            }
        }

        calculateNumberOfPages(categoryIndexToDoStuffWith, isCategoryFavorites)
        appsGridPagesRepeater.model = pageCount
        appsSwipeview.updateGridModel(categoryIndexToDoStuffWith, isCategoryFavorites)
    }

    // Functions to call from our search bar to manage this grid.
    function showSearchResults() {
        calculateNumberOfPages(-1, true) // HACK - search results is only a page like favorites is
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

    function changePage(pageNumber) {
        log("Change page from"+ appsSwipeview.currentIndex+ "to"+pageNumber)
        appsSwipeview.setCurrentIndex(pageNumber)
        log(appsSwipeview.currentIndex)
    }

    SwipeView {

        id: appsSwipeview

        signal updateGridModel(int myCategoryIndex, bool isFavorite)
        signal changeToSearchModel()
        signal tryActivateItemAt(int row, int column)

        anchors.fill: parent
        clip: true
        spacing: units.largeSpacing * 5

        Repeater {

            id: appsGridPagesRepeater
            model: pageCount

            ItemGridView {

                id: appsGridPage
                cellWidth:  cellSize
                cellHeight: cellSize

                Rectangle {
                    z: -1 // draw this element under the ItemGridView
                    height: parent.height
                    width: parent.width
                    color:Qt.rgba(theme.backgroundColor.r, theme.backgroundColor.g, theme.backgroundColor.b,  plasmoid.configuration.showItemGridBackground * plasmoid.configuration.itemGridTransparency)
                    border.color: Qt.rgba(theme.highlightColor.r,theme.highlightColor.g,theme.highlightColor.b,plasmoid.configuration.showItemGridBackground * plasmoid.configuration.itemGridTransparency)
                    border.width: Math.floor(units.smallSpacing/2)
                    radius: units.smallSpacing
                }

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

                onKeyNavDown: { //TODO: this needs some work to communicate where to return if we are pressing the "up" key on sessionControlBar
                    if (favoritesLoader.active) {
                        currentIndex = -1
                        favoritesLoader.item.tryActivate(0,0)
                    }
                }

                Connections {
                    target: appsSwipeview

                    function onUpdateGridModel(myCategoryIndex, isFavorite) { // magic function that assigns the right model according to myCategoryIndex and whether or not the category is "Favorites"
                        //console.log("ntro",index) // counting how many times this processor-heavy function is called. (For lower-end devices optimization purposes)
                        if (myCategoryIndex == allAppsIndex)  // we are either going to show favorites or all apps
                            if (isFavorite)
                                appsGridPage.model = rootModel.modelForRow(myCategoryIndex).modelForRow(0)
                            else
                                appsGridPage.model = rootModel.modelForRow(myCategoryIndex).modelForRow(index + 1)// shift first "All applications" index to account for the "Favorites" category
                        else if (myCategoryIndex <= allAppsIndex) // show either recent docs or recent apps
                            appsGridPage.model = rootModel.modelForRow(myCategoryIndex)
                        else // show a generic category
                            appsGridPage.model = rootModel.modelForRow(myCategoryIndex).modelForRow(index)
                    }

                    function onChangeToSearchModel() {
                        appsGridPage.model = runnerModel.modelForRow(0)
                    }

                    function onTryActivateItemAt(row,column) { // highlight item at coordinates (row, column) in the visible grid
                        if (appsSwipeview.currentIndex == index)
                            appsGridPage.tryActivate(row, column)
                            
                    }
                }
            }
        }

    }
}
