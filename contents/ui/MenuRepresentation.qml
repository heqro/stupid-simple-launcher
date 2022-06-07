/***************************************************************************
 *   Copyright (C) 2014 by Weng Xuetian <wengxt@gmail.com>                 *
 *   Copyright (C) 2013-2017 by Eike Hein <hein@kde.org>                   *
 *   Copyright (C) 2021-2022 by Hector Iglesias <heqromancer@gmail.com>    *
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
import QtQml.Models 2.4


// for vanilla scrollview
import QtQuick.Controls 2.2

Kicker.DashboardWindow {
    
    id: root

    property int iconSize:    plasmoid.configuration.iconSize // if iconSize == 48 then the icons' size will be 48x48. Enormous will make them look decent (in my screen, that is! :-) )

    property int cellSize: iconSize + Math.floor(1.5 * PlasmaCore.Theme.mSize(PlasmaCore.Theme.defaultFont).height)
        + (2 * PlasmaCore.Units.smallSpacing)
        + (2 * Math.max(highlightItemSvg.margins.top + highlightItemSvg.margins.bottom,
                        highlightItemSvg.margins.left + highlightItemSvg.margins.right))


    backgroundColor: "transparent"

    // whenever a key is pressed that is not "grabbed" by anything with focus by our application, the search field will react to it
    keyEventProxy: searchField


    property int columns: Math.floor(0.8 * Math.ceil(width / cellSize))

    property int widthScreen:  columns * cellSize

    // this property is exposed because it will determine the behavior of the grid - whenever we are searching, we will have only a grid dedicated to it. However, when we aren't, we may have two (if favorites support is enabled). It also determines which model we feed to the applications grid.
    property bool searching: searchField.text != ""
    property string searchText: searchField.text

    // we will only show a grid dedicated towards favorites when the user tells us to do so and we have at least an application checked as favorite
    property bool showFavoritesInGrid: plasmoid.configuration.favoritesInGrid && globalFavorites.count > 0

    property bool showCategories: plasmoid.configuration.showCategories

    property real alphaValue: plasmoid.configuration.opacitySet ? plasmoid.configuration.alphaValue : 0.8

    // boolean values to manage how to show categories in their corresponding sidebar
    property bool showCategoriesIcon: plasmoid.configuration.categoriesIcon
    property bool showCategoriesText: plasmoid.configuration.categoriesText
    property bool showCategoriesIconAndText: plasmoid.configuration.categoriesIconAndText

    property bool showCategoriesTooltip: plasmoid.configuration.showCategoriesTooltip

    property bool showCategoriesOnTheRight: plasmoid.configuration.showCategoriesOnTheRight

    // boolean value to know whether or not the user wants the menu to drop the user right into the favorites section instead of the "All applications" section on startup.
    property bool startOnFavorites: plasmoid.configuration.startOnFavorites
    property int favoritesCategoryIndex: 1

    property bool customizeCategoriesSidebarSize: plasmoid.configuration.customizeCategoriesButtonSize
    property int categoriesSidebarWidth: plasmoid.configuration.categoriesButtonWidth

    property var hiddenApps: plasmoid.configuration.hiddenApplicationsName

    // cool function to tweak transparency I took from the original launchpad
    function colorWithAlpha(color, alpha) {
        return Qt.rgba(color.r, color.g, color.b, alpha)
    }

    onKeyEscapePressed: { // using escape for either closing the menu or stopping the search

        if (searchField.activeFocus || searching) { // unfocus when escape key is pressed
            searchField.focus = false
            searchField.text = ""
        } else {
            root.toggle()
        }
    }

    onHiddenAppsChanged: {
        rootModel.refresh()
    }

    onSearchingChanged: {
        if (!searching)
            reset("searchingChanged")
    }

    onSearchTextChanged: {
        if (searchField.text != "") {
            appsGridLoader.item.updateQuery(searchField.text)
            appsGridLoader.item.showSearchResults()
        }
    }

    onVisibleChanged: {
        if (visible) // start fancy animation
            animationSearch.start()
        else { // only perform heavy calculations to return to last known state when menu is exited
            reset("visibleChanged -> false")
        }
    }

    onStartOnFavoritesChanged: {
        reset("startOnFavorites changed: " + startOnFavorites)
    }

    function reset(reason) { // return everything to the last known state
        log("Resetting... "+reason)

        searchField.text = "" // force placeholder text to be shown
        searchField.focus = false

        if (favoritesLoader.active)
            favoritesLoader.item.currentIndex = -1 // don't highlight current item on the favorites grid

        var startCategoryIndex = startOnFavorites ? - 1 : appsGridLoader.allAppsIndex
        appsGridLoader.item.resetAppsGrid()
//         appsGridLoader.item.changeCategory(startCategoryIndex)

        if (startOnFavorites) {
            if (showCategories) {
                if (plasmoid.configuration.showFavoritesCategory)
                    categoriesList.currentIndex = favoritesCategoryIndex // highlight "Favorites" category
                else
                    categoriesList.currentIndex = -1
            }

        } else {
            if (showCategories) {
                categoriesList.currentIndex = 0 // highlight first category on the list (always will be "All applications")
            }
        }



    }

    mainItem:

        MouseArea {

            id: mainItemRoot
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            LayoutMirroring.enabled: Qt.application.layoutDirection == Qt.RightToLeft
            LayoutMirroring.childrenInherit: true

            ScaleAnimator{
                id: animationSearch
                from: 1.1
                to: 1
                target: mainItemRoot
            }

            onClicked: {
                // when clicked inside this area and outside the applications grid or any cool buttons, register it as if the user wanted to get out of the menu
                if (plasmoid.configuration.clickToToggle)
                    root.toggle();
            }

            Rectangle{
                anchors.fill: parent
                color: colorWithAlpha(theme.backgroundColor, alphaValue)
            }

            ColumnLayout {

                id: mainColumn
                anchors.fill: parent

                SearchBar {

                    id: searchField

                    writeSomething:  plasmoid.configuration.writeSomething
                    greetingText:    plasmoid.configuration.greetingText
                    searchBarDesign: plasmoid.configuration.searchBarDesign
                    searchBarOpacity:plasmoid.configuration.searchBarOpacity

                    Layout.alignment: Qt.AlignCenter
                    Layout.fillWidth: true
                    Layout.topMargin: units.iconSizes.large
                    Layout.bottomMargin: units.iconSizes.medium
                    Layout.maximumWidth: searchField.usedSpace // expand the search field's width as much as the design requires space work with. Some designs are dynamic when it comes to their width, thus we need to account for this change.

                    Keys.onPressed: {
                        if (event.key == Qt.Key_Down || event.key == Qt.Key_Right) {
                            event.accepted = true
                            appsGridLoader.item.highlightItemAt(0, 0)
                        } else if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter) {
                            if (searching && runnerModel.count >= 1) {
                                event.accepted = true
                                appsGridLoader.item.highlightItemAt(0,0)
                                appsGridLoader.item.itemGrid.model.trigger(0, "", null);
                                root.toggle()
                            }

                        }

                    }
                }



                RowLayout {

                    id: appsGridPlusCategories

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignCenter
                    Layout.bottomMargin: units.iconSizes.large

                    layoutDirection: showCategoriesOnTheRight ? Qt.LeftToRight : Qt.RightToLeft

                    Item {
                        id: appGridsRectangle

                        Layout.fillWidth: true
                        Layout.fillHeight:true
                        Loader {
                            id: appsGridLoader
                            readonly property int allAppsIndex: rootModel.showRecentApps + rootModel.showRecentDocs
                            readonly property int startCategoryIndex: plasmoid.configuration.startOnFavorites ? -1 : allAppsIndex

                            height: plasmoid.configuration.paginateGrid ? cellSize * Math.floor((parent.height - (favoritesLoader.height + units.largeSpacing) * favoritesLoader.active - (pageIndicatorLoader.height + units.largeSpacing) * pageIndicatorLoader.active) / cellSize) : parent.height - (favoritesLoader.height + units.largeSpacing) * favoritesLoader.active - pageIndicatorLoader.height * pageIndicatorLoader.active
//                                 anchors.top: plasmoid.configuration.paginateGrid ? : parent.top

                            anchors.top: parent.top
                            width: cellSize * Math.floor(parent.width / cellSize)
                            anchors.horizontalCenter: parent.horizontalCenter
//                                 anchors.left: parent.left
                            //anchors.right: parent.right
                            source: plasmoid.configuration.paginateGrid ? "PaginatedApplicationsGrid.qml" : "ApplicationsGrid.qml"

                        }
                        Loader { // dots to show the current page and the amount of pages.
                            id: pageIndicatorLoader
                            active: plasmoid.configuration.paginateGrid
                            anchors.top: appsGridLoader.bottom

                            anchors.topMargin: units.largeSpacing
                            anchors.horizontalCenter: parent.horizontalCenter

                            sourceComponent: PageIndicator {

                                id: currentPageIndicator

                                visible: !searching && count != 1

                                count: appsGridLoader.item.pageCount
                                currentIndex: appsGridLoader.item.currentIndex
//                                     interactive: true

                                delegate: Rectangle {

                                    color: theme.headerTextColor
                                    opacity: index === currentPageIndicator.currentIndex ? 0.75 : (indicatorMouseArea.containsMouse ? 0.5 : 0.35)
                                    height: index === currentPageIndicator.currentIndex ? units.iconSizes.smallMedium : units.iconSizes.small
                                    width:  height
                                    radius: height / 2
                                    anchors.verticalCenter: parent.verticalCenter // align all indicators

                                    Behavior on width { SmoothedAnimation {velocity: 12; easing.type: Easing.OutQuad} }

                                    MouseArea {
                                        id: indicatorMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: { appsGridLoader.item.changePage(index) } // send to the apps grid the order to change page
                                    }

                                }
                            }
                        }

                        Loader { // we can get away with not setting this boys' width because the loaded item will give such info
                            id: favoritesLoader
                            active: showFavoritesInGrid
                            anchors.bottom: parent.bottom
                            anchors.topMargin: units.largeSpacing
                            height: plasmoid.configuration.favoritesIconSize
                            anchors.horizontalCenter: parent.horizontalCenter

                            sourceComponent: ItemGridView {
                                model: globalFavorites
                                cellWidth: parent.height
                                cellHeight: parent.height
                                showLabels: false
                                dragEnabled: true
                                width: Math.min(globalFavorites.count * parent.height, cellWidth * Math.floor(appGridsRectangle.width / cellWidth)) // TODO - if the favorites is higher than the width then add an extra button to show all favorites!

                                onKeyNavUp: {
                                    currentIndex = -1
                                    appsGridLoader.item.highlightItemAt(0,0)
                                }

                                Rectangle {
                                    z: -1 // draw this element under the ItemGridView
                                    height: parent.height
                                    width: parent.height * Math.floor(parent.width / parent.height)
                                    color: colorWithAlpha(theme.backgroundColor, alphaValue * 0.6)
                                    border.color: colorWithAlpha(theme.highlightColor, 1)
                                    border.width: Math.floor(units.smallSpacing/2)
                                    radius: units.smallSpacing

                                }
                            }


                        }
                    }

                    PlasmaComponents3.ScrollView { // dedicated to storing the categories list

                        id: categoriesItem

                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        Layout.maximumWidth: categoriesModel.count == 0 ? 0 : (customizeCategoriesSidebarSize ? Math.ceil(categoriesSidebarWidth + units.iconSizes.medium) : Math.floor(widthScreen / 8 + units.iconSizes.medium)) // adding up a little bit of "artificial" size to let the category button breathe with respect to the sidebar's scrollbar.
                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                        ListView {

                            id: categoriesList

                            anchors.fill: parent

                            model: ObjectModel {
                                id: categoriesModel
                            }


                            // only add some fancy spacing between the buttons if they are only icons.
                            spacing: showCategoriesIcon ? units.iconSizes.small : 0

                            // the following lines help maintaining consistency in highlighting with respect to whatever you have set in your Plasma Style. (This is taken from ItemGridDelegate.qml)
                            highlight: PlasmaComponents.Highlight {}
                            highlightFollowsCurrentItem: true
                            highlightMoveDuration: 0

                            Connections {
                                target: rootModel

                                function onCountChanged() { // make sure categories are only updated when rootModel really changes (to avoid repeating the same calculation when it's not needed)
                                    updateCategories()
                                }

                                function onShowRecentDocsChanged() {
                                    updateCategories()
                                    reset("showRecentDocsChanged")
                                }

                                function onShowRecentAppsChanged() {
                                    updateCategories()
                                    reset("showRecentAppsChanged")
                                }

                                function updateCategories() { // build categoriesModel

                                    function addToModel(modelKey, indexInCategoriesModel) { // generic append function
                                        component = Qt.createComponent("CategoryButton.qml")
                                        if (component.status == Component.Ready)
                                            finishCreation(modelKey,indexInCategoriesModel);
                                        else
                                            component.statusChanged.connect(finishCreation);
                                    }
                                    function finishCreation(modelKey, indexInCategoriesModel) {
                                        var modelIndex = rootModel.index(modelKey, 0)
                                        var categoryLabel = rootModel.data(modelIndex, Qt.DisplayRole)
                                        var categoryIcon = rootModel.data(modelIndex, Qt.DecorationRole)

                                        const modelCount = categoriesModel.count

                                        var object = component.createObject(categoriesList, {
                                            indexInModel: indexInCategoriesModel,
                                            categoryName: categoryLabel
                                        })
                                        object.setSourceIcon(categoryIcon)

                                        categoriesModel.append(object)
                                        object.changeCategoryRequested.connect(function() {
                                            appsGridLoader.item.changeCategory(object.indexInModel)
                                            appsGridLoader.item.highlightItemAt(0, 0)
                                            categoriesList.currentIndex = modelCount
                                        })

                                    }

                                    function addFavoritesToModel() {
                                        if (plasmoid.configuration.showFavoritesCategory) { // manually create favorites category button (because this info cannot be reached with the rest of the tools)
                                            var component = Qt.createComponent("CategoryButton.qml")
                                            var object = component.createObject(categoriesList, {
                                                indexInModel: -1,
                                                categoryName: i18n("Favorites")
                                            })
                                            object.setSourceIcon("favorite")
                                            const modelCount = categoriesModel.count
                                            categoriesModel.append(object)
                                            object.changeCategoryRequested.connect(function() {
                                                appsGridLoader.item.changeCategory(-1)
                                                appsGridLoader.item.highlightItemAt(0, 0)
                                                categoriesList.currentIndex = modelCount
                                            })
                                        }
                                    }

                                    function addMetaCategoriesToModel() { // sui generis append function to add hard-coded categories (Favorites, Recent Docs, Recent Apps)
                                        if (rootModel.showRecentDocs)
                                            addToModel(rootModel.showRecentApps, -2)
                                        if (rootModel.showRecentApps)
                                            addToModel(0, -3)
                                    }

                                    var component

                                    var categoryStartIndex = rootModel.showRecentDocs + rootModel.showRecentApps // rootModel adds recent docs and recent apps to the very start of it. We skip these metacategories (if they are to be present) to add them right after "All applications".
                                    var categoryEndIndex = rootModel.count

                                    categoriesModel.clear() // preemptive action

                                    addToModel(categoryStartIndex, categoryStartIndex) // manually add "All apps" category (to make sure the meta-categories & favorites are added right after it)
                                    addFavoritesToModel()
                                    addMetaCategoriesToModel()
                                    for (var i = categoryStartIndex + 1; i < categoryEndIndex; i++) // add the rest of "normal" categories
                                        addToModel(i, i)
                                }
                            }

                        }
                    }

                }

                Loader {
                    visible: plasmoid.configuration.showSessionControlBar
                    active: plasmoid.configuration.showSessionControlBar
                    sourceComponent: SessionControlBar {
                        showButtonTooltips: plasmoid.configuration.showSessionControlTooltips
                    }
                    Layout.alignment: Qt.AlignCenter | Qt.AlignBottom
                    Layout.bottomMargin: units.iconSizes.smallMedium
                }
            }
        }

    Component.onCompleted: {
        // Dummy query to preload runner model
        appsGridLoader.item.updateQuery("k")
        appsGridLoader.item.showSearchResults()
        reset("MenuRepresentation is ready -> Component.onCompleted()")
        appsGridLoader.loaded.connect(function resetBecauseOfLoad() {reset("appsGridLoader loaded")})
        kicker.reset.connect(function resetBecauseOfKicker() {
            if (appsGridLoader.item) reset("Kicker reset")
            else log("Won't reset (Component is loading and will reset once it is done loading)")
        });

    }
}

