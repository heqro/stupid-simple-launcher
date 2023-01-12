import QtQuick 2.4

import org.kde.plasma.plasmoid 2.0

import org.kde.plasma.private.kicker 0.1 as Kicker

import "../code/tools.js" as Tools
import QtQuick.Window 2.0
import QtQuick.Controls.Styles 1.4

Item {

    function resetAppsGrid() {
        rootModel.pageSize = -1
        if (startOnFavorites) {
            appsGrid.model = rootModel.modelForRow(allAppsIndex).modelForRow(0)
        } else {
            appsGrid.model = rootModel.modelForRow(allAppsIndex).modelForRow(1)
        }
        appsGrid.focus = true
        highlightItemAt(0,0)
    }

    function changeCategory(appsGridModelKey) {
        switch (appsGridModelKey) {
            case -1: { // Favorites are hard-tagged as index -1
                appsGrid.model = rootModel.modelForRow(allAppsIndex).modelForRow(0)
                break
            }
            case -2: { // Recent documents are hard-tagged as index -2
                appsGrid.model = rootModel.modelForRow(1)
                break
            }
            case -3: { // Recent Applications are hard-tagged as index -3
                appsGrid.model = rootModel.modelForRow(0)
                break
            }
            case allAppsIndex: { // All Applications
                appsGrid.model = rootModel.modelForRow(allAppsIndex).modelForRow(1)
                break
            }
            default: { // Show generic category
                appsGrid.model = rootModel.modelForRow(appsGridModelKey).modelForRow(0)
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
        appsGrid.tryActivate(row, column)
    }

    id: artifactForProperlyDisplayingEverythingInANiceWay
    anchors.fill: parent

    readonly property int pageCount: 1
    readonly property int currentIndex: 1

    ScrollableItemGridView { // this is actually the applications grid

        id: appsGrid
        anchors.fill: parent

        cellWidth:  cellSize
        cellHeight: cellSize

        onKeyNavUp: {
            currentIndex = -1;
            searchField.focus = true
        }

        onKeyNavDown: { //TODO: this needs some work to communicate where to return if we are pressing the "up" key on sessionControlBar
            if (favoritesLoader.active) {
                currentIndex = -1
                favoritesLoader.item.tryActivate(0,0)
            }
        }

        onModelChanged: { // when we stop userIsSearching or start userIsSearching, highlight the first item just to give the user a hint that pressing "Enter" will launch the first entry.
            currentIndex = 0
            //appsGrid.itemGrid.tryActivate(0, 0);
        }
    }


}
