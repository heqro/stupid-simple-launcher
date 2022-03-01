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

    //property int allAppsCount: rootModel.modelForRow(0).count
    //onAllAppsCountChanged: {
        //console.log("Updated model as new stuff was added.")
        //console.log("All apps count", allAppsCount)
    //}

    function resetAppsGrid() {
//         appsGrid.focus = true
//         if (startOnFavorites) {
//             appsGrid.model = rootModel.modelForRow(rootModel.showRecentApps + rootModel.showRecentDocs).modelForRow(0)
//         } else {
//             appsGrid.model = rootModel.modelForRow(rootModel.showRecentApps + rootModel.showRecentDocs).modelForRow(1)
//         }
        //appsGrid.model = rootModel.modelForRow(0).modelForRow(1)
        appsRectangle.updateCoso()
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
//         if (myFavorites.visible)
//             myFavorites.tryActivate(row, column)
//         else

            appsGrid.tryActivate(row, column)
    }

    id: artifactForProperlyDisplayingEverythingInANiceWay
    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.bottomMargin: plasmoid.configuration.showSessionControlBar ? units.iconSizes.medium : units.iconSizes.large


    ColumnLayout {

        id: appsStuff

        anchors.fill: parent

        SwipeView {

            id: appsRectangle

            Layout.fillWidth: true
            Layout.fillHeight: true

            signal updateCoso()

            clip: true

            // akí va un ripíter como una casa. hay tantos model como pageCount
            Repeater {
                model: pageCount
                ItemGridView {
                    id: appsGridPage
                    cellWidth:  cellSize
                    cellHeight: cellSize
//                     model: rootModel.modelForRow(0).modelForRow(index)
                    //onKeyNavUp: {
                        //console.log("MODEL COUNT",model.count)
                        //currentIndex = -1;
                        //if (showFavoritesInGrid && !searching) {
                            //myFavorites.tryActivate(0,0)
                        //} else {
                            //searchField.focus = true;
                        //}
                    //}

                    Connections{
                        target: appsRectangle
                        onUpdateCoso: {
                            console.log("UPDATIADO")
                            appsGridPage.model = rootModel.modelForRow(0).modelForRow(index + 1)
                        }
                    }
                }
            }

        }


    }
}
