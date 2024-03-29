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

import QtQuick 2.7

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

// GaussianBlur
import QtGraphicalEffects 1.0

Kicker.DashboardWindow {
    
    id: root

    property int applicationButtonHeight: plasmoid.configuration.applicationButtonHeight
    property int applicationButtonWidth: plasmoid.configuration.applicationButtonWidth

    backgroundColor: "transparent"

    // whenever a key is pressed that is not "grabbed" by anything with focus by our application, the search field will react to it
    keyEventProxy: searchField

    property int columns: Math.floor(0.8 * Math.ceil(width / applicationButtonWidth))

    property int widthScreen:  columns * applicationButtonWidth

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

    function getCategoriesList() {
        if (!showCategories) return
        if (categoriesLoader.item) return categoriesLoader.item
    }

    onKeyEscapePressed: { // using escape for either closing the menu or stopping the search

        if (searchField.isSearchBarFocused) { // unfocus when escape key is pressed
            searchField.unfocus()
            appsGridLoader.item.changeCategory(appsGridLoader.allAppsIndex)
            appsGridLoader.item.highlightItemAt(0, 0)
            getCategoriesList().setCurrentIndex(0)
        } else {
            root.toggle()
        }
    }

    onSearchingChanged: {
        if (!searching)
            reset("searchingChanged")
    }

    onSearchTextChanged: {
        if (searchField.text != "") {
            appsGridLoader.item.updateQuery(searchField.text)
            appsGridLoader.item.showSearchResults()
        } else {
            appsGridLoader.item.resetAppsGrid()
        }
    }

    onVisibleChanged: {
        if (visible) {
            animationSearch.start() // start fancy animation
            appsGridLoader.item.resetAppsGrid()
        }
        else { // only perform heavy calculations to return to last known state when menu is exited
            searchField.unfocus()
            reset("visibleChanged -> false")
        }
    }

    onStartOnFavoritesChanged: {
        reset("startOnFavorites changed: " + startOnFavorites)
    }

    function reset(reason) { // return everything to the last known state
        log("Resetting... "+reason)

        if (favoritesLoader.active && favoritesLoader.state == Loader.Ready)
            favoritesLoader.item.currentIndex = -1 // don't highlight current item on the favorites grid
        if (appsGridLoader.state == Loader.Ready)
            appsGridLoader.item.resetAppsGrid()

        if (plasmoid.configuration.showFavoritesCategory && showCategories && getCategoriesList().item)
            getCategoriesList().positionViewAtBeginning()

        if (startOnFavorites) {
            if (showCategories) {
                if (plasmoid.configuration.showFavoritesCategory)
                    getCategoriesList().setCurrentIndex(favoritesCategoryIndex) // highlight "Favorites" category
                else
                    getCategoriesList().setCurrentIndex(-1)
            }
        } else {
            if (showCategories) {
                getCategoriesList().setCurrentIndex(0) // highlight first category on the list (always will be "All applications")
            }
        }
    }

    mainItem:

        MouseArea {

            id: mainItemRoot

            width: Screen.width
            height: Screen.height

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

            Image {
                id: backgroundImageLoader
                visible: plasmoid.configuration.isBackgroundImageSet
                anchors.fill: parent;
                source: plasmoid.configuration.backgroundImage
                fillMode: Image.PreserveAspectCrop;
            }

            Rectangle{
                visible: !plasmoid.configuration.isBackgroundImageSet || backgroundImageLoader.status != Image.Ready
                anchors.fill: parent
                color:Qt.rgba(theme.backgroundColor.r, theme.backgroundColor.g, theme.backgroundColor.b,  alphaValue)
            }

            SearchBar {

                id: searchField
                z: 1 // show above the blur effect

                writeSomething:  plasmoid.configuration.writeSomething
                greetingText:    plasmoid.configuration.greetingText
                searchBarDesign: plasmoid.configuration.searchBarDesign
                searchBarOpacity:plasmoid.configuration.searchBarOpacity

                anchors {
                    top: parent.top
                    topMargin:    units.largeSpacing * 2
                    horizontalCenter: parent.horizontalCenter
                }

                width: Math.min(parent.width, searchField.usedSpace)

                Keys.onPressed: {
                    if (event.key == Qt.Key_Down || event.key == Qt.Key_Right) {
                        event.accepted = true
                        appsGridLoader.item.highlightItemAt(0, 0)
                    } else if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter) {
                        event.accepted = true
                        appsGridLoader.item.triggerFirstEntry()
                    }
                }
            }

            // Wallpaper blur
            ShaderEffectSource {
                id: backgroundShader
                sourceItem: backgroundImageLoader
                height: parent.height
                width: parent.width
                sourceRect: Qt.rect(x,y,width,height)
                visible: plasmoid.configuration.isBackgroundImageSet && plasmoid.configuration.isBlurEnabled && plasmoid.configuration.isWallpaperBlurred
            }

            GaussianBlur {
                visible: plasmoid.configuration.isBackgroundImageSet && plasmoid.configuration.isBlurEnabled && plasmoid.configuration.isWallpaperBlurred
                source: backgroundShader
                anchors.fill: backgroundShader
                radius: plasmoid.configuration.blurRadius
                samples:plasmoid.configuration.blurSamples
            }

            // Items blur
            ShaderEffectSource {
                visible: plasmoid.configuration.isBackgroundImageSet && plasmoid.configuration.isBlurEnabled && !plasmoid.configuration.isWallpaperBlurred
                id: appsGridShader
                sourceItem: backgroundImageLoader
                height:appsGridLoader.height
                width: appsGridLoader.width
                anchors.top: appsGridPlusCategories.top
                sourceRect: Qt.rect(x,y,width,height)
            }

            GaussianBlur {
                visible: plasmoid.configuration.isBackgroundImageSet && plasmoid.configuration.isBlurEnabled && !plasmoid.configuration.isWallpaperBlurred
                anchors.fill: appsGridShader
                source: appsGridShader
                radius: plasmoid.configuration.blurRadius
                samples:plasmoid.configuration.blurSamples
            }

            ShaderEffectSource {
                visible: plasmoid.configuration.isBackgroundImageSet && plasmoid.configuration.isBlurEnabled && !plasmoid.configuration.isWallpaperBlurred
                id: categoriesListShader
                sourceItem: backgroundImageLoader
                height: showCategories * categoriesLoader.height
                width: showCategories * categoriesLoader.width
                anchors.top: appsGridPlusCategories.top
                anchors.left: appsGridPlusCategories.left
                sourceRect: Qt.rect(x,y,width,height)
            }

            GaussianBlur {
                visible: plasmoid.configuration.isBackgroundImageSet && plasmoid.configuration.isBlurEnabled && !plasmoid.configuration.isWallpaperBlurred
                anchors.fill: categoriesListShader
                source: categoriesListShader
                radius: plasmoid.configuration.blurRadius
                samples:plasmoid.configuration.blurSamples
            }

            ShaderEffectSource {
                visible: plasmoid.configuration.isBackgroundImageSet && plasmoid.configuration.isBlurEnabled && !plasmoid.configuration.isWallpaperBlurred
                id: favoritesShader
                sourceItem: backgroundImageLoader
                height: favoritesLoader.height
                width: favoritesLoader.width
                x: favoritesLoader.x
                y: favoritesLoader.y + favoritesLoader.usedHeight
                sourceRect: Qt.rect(x,y,width,height)
            }

            ShaderEffectSource {
                id: sessionControlBarShader
                visible: plasmoid.configuration.isBackgroundImageSet && plasmoid.configuration.isBlurEnabled && !plasmoid.configuration.isWallpaperBlurred
                sourceItem: backgroundImageLoader
                height: sessionControlBarLoader.height
                width: sessionControlBarLoader.width
                anchors.bottom: sessionControlBarLoader.bottom
                anchors.left: sessionControlBarLoader.left
                sourceRect: Qt.rect(x,y,width,height)
            }

            GaussianBlur {
                visible: plasmoid.configuration.isBackgroundImageSet && plasmoid.configuration.isBlurEnabled && !plasmoid.configuration.isWallpaperBlurred
                anchors.fill: sessionControlBarShader
                source: sessionControlBarShader
                radius: plasmoid.configuration.blurRadius
                samples:plasmoid.configuration.blurSamples
            }

            Row {

                id: appsGridPlusCategories
                layoutDirection: showCategories && showCategoriesOnTheRight ? Qt.RightToLeft : Qt.LeftToRight

                anchors {
                    top: searchField.bottom
                    bottom: sessionControlBarLoader.active ? sessionControlBarLoader.top : parent.bottom
                    topMargin: units.largeSpacing
                    bottomMargin: units.largeSpacing
                    right: parent.right
                    left: parent.left
                }

                Loader {
                    id: categoriesLoader
                    active: showCategories

                    height: parent.height
                    width: active * Math.ceil(categoriesSidebarWidth + units.iconSizes.medium)

                    sourceComponent: CategoriesList {
                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                        Rectangle {
                            height: parent.height
                            width: categoriesSidebarWidth
                            color: Qt.rgba(theme.backgroundColor.r, theme.backgroundColor.g, theme.backgroundColor.b,  plasmoid.configuration.categoriesTransparency)
                            visible: plasmoid.configuration.showCategoriesBackground
                        }
                    }
                    onLoaded: item.updateCategories()
                }

                Item {

                    id: appsGrid
                    height: parent.height
                    width: parent.width - categoriesLoader.width

                    Loader {

                        id: appsGridLoader

                        readonly property int allAppsIndex: rootModel.showRecentApps + rootModel.showRecentDocs
                        readonly property int startCategoryIndex: plasmoid.configuration.startOnFavorites ? -1 : allAppsIndex
                        readonly property int availableHeight: parent.height - pageIndicatorLoader.usedHeight - favoritesLoader.usedHeight

                        height: plasmoid.configuration.paginateGrid ? applicationButtonHeight * Math.floor(availableHeight / applicationButtonHeight) : availableHeight
                        width: applicationButtonWidth * Math.floor((parent.width - !plasmoid.configuration.paginateGrid * 50) / applicationButtonWidth) // 50 is a little bit higher than the usual scrollbar width. We are implicitly making room for it with this expression (when we are using the scrollable version).

                        anchors {
                            top: parent.top
                            horizontalCenter: parent.horizontalCenter
                        }

                        onLoaded: {
                            appsGridLoader.item.updateQuery("k")
                            appsGridLoader.item.showSearchResults()
                            reset('appsGridLoader -> onLoaded')
                            if (!plasmoid.configuration.paginateGrid)
                                rootModel.pageSize = -1 // this automatically triggers a reset on Kicker. Allows ApplicationsGrid.qml to properly work on first launch.
                        }

                        Component.onCompleted: {
                            source = Qt.binding(function() {return plasmoid.configuration.paginateGrid ? "PaginatedApplicationsGrid.qml" : "ApplicationsGrid.qml"}) // load the component only after knowing the screen real estate we will have
                        }

                        Connections {
                            id: hiddenAppsListener
                            target: root
                            enabled: false
                            function onHiddenAppsChanged() {
                                rootModel.refresh()
                                appsGridLoader.item.resetAppsGrid()
                            }
                        }

                    }

                    Loader { // dots to show the current page and the amount of pages.
                        id: pageIndicatorLoader
                        active: plasmoid.configuration.paginateGrid

                        readonly property int usedHeight: (height + anchors.topMargin) * active

                        anchors {
                            top: appsGridLoader.bottom
                            topMargin: units.smallSpacing * active
                            horizontalCenter: parent.horizontalCenter
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: mouse.accepted = true // prevent the menu from closing by misclicking in the space between the delegates
                        }

                        sourceComponent: PageIndicator {

                            id: currentPageIndicator

                            visible: !searching && count != 1

                            count: appsGridLoader.item.pageCount
                            currentIndex: appsGridLoader.item.currentIndex

                            delegate: Rectangle {

                                color: theme.headerTextColor
                                border.color: index === currentPageIndicator.currentIndex ? theme.buttonFocusColor : theme.highlightColor
                                border.width: Math.floor(0.7 * units.smallSpacing)
                                opacity: index === currentPageIndicator.currentIndex ? 0.75 : (indicatorMouseArea.containsMouse ? 0.5 : 0.35)
                                height: index === currentPageIndicator.currentIndex ? units.iconSizes.medium : units.iconSizes.smallMedium
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

                        readonly property int usedHeight: (height + anchors.topMargin) * active
                        readonly property int parentWidth: parent.width

                        anchors {
                            topMargin: units.mediumSpacing * active
                            bottom: parent.bottom
                            horizontalCenter: parent.horizontalCenter
                        }

                        GaussianBlur {
                            visible: plasmoid.configuration.isBackgroundImageSet && plasmoid.configuration.isBlurEnabled && !plasmoid.configuration.isWallpaperBlurred
                            width: favoritesShader.width * favoritesLoader.active
                            height: favoritesShader.height * favoritesLoader.active
                            source: favoritesShader
                            radius: plasmoid.configuration.blurRadius
                            samples:plasmoid.configuration.blurSamples
                        }

                        height: plasmoid.configuration.favoritesIconSize

                        sourceComponent: ScrollableItemGridView {
                            id: favoritesGridView
                            model: globalFavorites
                            cellWidth: plasmoid.configuration.favoritesIconSize
                            cellHeight: plasmoid.configuration.favoritesIconSize
                            showLabels: false
                            dragEnabled: true
                            width: Math.min(cellWidth * Math.floor(parentWidth / cellWidth), cellWidth * globalFavorites.count)
                            height: cellHeight
                            anchors.horizontalCenter: parent.horizontalCenter
                            isFlowVertical: false

                            onKeyNavUp: {
                                currentIndex = -1
                                appsGridLoader.item.highlightItemAt(0,0)
                            }
                        }
                    }
                }
            }

            Loader {
                id: sessionControlBarLoader
                visible: plasmoid.configuration.showSessionControlBar
                active: plasmoid.configuration.showSessionControlBar
                sourceComponent: SessionControlBar {
                    showButtonTooltips: plasmoid.configuration.showSessionControlTooltips
                }
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                    bottomMargin: active ? units.iconSizes.smallMedium : 0
                }

                Rectangle {
                    z: -1 // draw this element under the ItemGridView
                    height: parent.height
                    width: parent.width
                    color:Qt.rgba(theme.backgroundColor.r, theme.backgroundColor.g, theme.backgroundColor.b,  plasmoid.configuration.showSessionControlBackground * plasmoid.configuration.sessionControlTransparency)
                    border.color: Qt.rgba(theme.highlightColor.r,theme.highlightColor.g,theme.highlightColor.b,plasmoid.configuration.showSessionControlBackground * plasmoid.configuration.sessionControlTransparency)
                    border.width: Math.floor(units.smallSpacing/2)
                    radius: units.smallSpacing
                }
            }
        }

    Component.onCompleted: {
        // Dummy query to preload runner model
        log('MenuRepresentation.qml onCompleted')
        kicker.reset.connect(function resetBecauseOfKicker() {
            if (appsGridLoader.state == Loader.Ready) {reset("Kicker reset")}
            else log("Won't reset (Component is loading and will reset once it is done loading)")
        });
        hiddenAppsListener.enabled = true // reduce first launch penalty by explicitly enabling the signal listener once the menu is finished loading

    }
}

