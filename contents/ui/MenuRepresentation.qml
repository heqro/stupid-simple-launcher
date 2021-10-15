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

// for using RowLayout
import QtQuick.Layouts 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.private.kicker 0.1 as Kicker

import "../code/tools.js" as Tools
import QtQuick.Window 2.0
import QtQuick.Controls.Styles 1.4

// user information is called by using this
import org.kde.kcoreaddons 1.0 as KCoreAddons


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
    property int rows: Math.floor(0.75 * Math.ceil(height / cellSize))

    property int widthScreen:  columns * cellSize
    property int heightScreen: rows    * cellSize

    // this property is exposed because it will determine the behavior of the grid - whenenver we are searching, we will have only a grid dedicated to it. However, when we aren't, we may have two (if favorites support is enabled). It also determines which model we feed to the applications grid.
    property bool searching: searchField.text != ""

    // we will only show a grid dedicated towards favorites when the user tells us to do so and we have at least an application checked as favorite
    property bool showFavoritesInGrid: plasmoid.configuration.favoritesInGrid && globalFavorites.count > 0

    //property bool showCategories: !plasmoid.configuration.hideCategories

    property real alphaValue: plasmoid.configuration.opacitySet ? plasmoid.configuration.alphaValue : 0.6

    // boolean values to manage how to show categories in their corresponing sidebar
    property bool showCategoriesIcon: plasmoid.configuration.categoriesIcon
    property bool showCategoriesText: plasmoid.configuration.categoriesText
    property bool showCategoriesIconAndText: plasmoid.configuration.categoriesIconAndText


    // cool function to tweak transparency I took from the original launchpad
    function colorWithAlpha(color, alpha) {
        return Qt.rgba(color.r, color.g, color.b, alpha)
    }

    onKeyEscapePressed: { // using escape for both closing the menu and stopping the search
        if (searching) {
            searchField.text = ""
        } else {
            root.toggle()
        }
    }

    onSearchingChanged: {
        if (searching) { // swap model
            pageList.model = runnerModel;
        } else { // we stopped searching - return everything to a basic known state
            reset();
        }
    }

    //onShowCategoriesChanged: {

        //if (showCategories) {
            //appsRectangle.anchors.left = parent.left
        //} else {
            //appsRectangle.anchors.horizontalCenter = parent.horizontalCenter
        //}

    //}

    onVisibleChanged: { // start fancy animation and preemptively return to a known state
        animationSearch.start()
        reset();
    }

//     function getDisplay() {
//         this function is used for determining the display of the categories sidebar (icons only, text only, text + icon)
//         var layout = AbstractButton.TextBesideIcon
//         if (showCategoriesIcon) {
//             layout = AbstractButton.IconOnly
//         } else if (showCategoriesText) {
//             layout = AbstractButton.TextOnly
//         }
//
//         return layout
//     }

    function updateCategories() { // this function is dedicated to constructing the applications categories list and preemptively updating it, should changes have been applied
        var categoryStartIndex = 0
        var categoryEndIndex = rootModel.count
        categoriesModel.clear() // given that we feed the model by appending items to it, it's only logical that we have to clear it every time we open the menu (just in case new applications have been installed)
        for (var i = categoryStartIndex; i < categoryEndIndex; i++) { // loop courtesy of Windows 10 inspired menu plasmoid

            if (i == 1 ) { // we are currently adding the category right after "All applications"
                // this is a great time to add Favorites support
                categoriesModel.append({"categoryText": i18n("Favorites"), "categoryIcon": "applications-featured", "categoryIndex": -1}) // we manually set -1 as category index to distinguish the Favorites category from the rest -- this for loop won't register Favorites as a category.
            }

            var modelIndex = rootModel.index(i, 0) // I don't know how this line works but it does
            var categoryLabel = rootModel.data(modelIndex, Qt.DisplayRole) // this is the name that will be shown in the list, say, "All applications", "Utilities", "Education", blah blah blah
            var categoryIcon = rootModel.data(modelIndex, Qt.DecorationRole)

            var aux = categoryIcon.toString().split('"') // the day the way this prints out changes I will have a huge problem

            var index = i // we will use this index to swap categories inside the model that feeds our applications grid
            categoriesModel.append({"categoryText": categoryLabel, "categoryIcon": aux[1],"categoryIndex": index})
        }
    }

    function reset() { // return everything to a last known state
        if (!searching) {
            pageList.model = rootModel.modelForRow(0).modelForRow(1) // show all applications
        }

        //if(showCategories) {
        updateCategories()
//         }

        pageList.focus = true
        searchField.text = ""
        pageList.currentItem.itemGrid.model = rootModel.modelForRow(0).modelForRow(1) // show all applications
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

                ScaleAnimator{
                    id: animationSearch
                    from: 1.1
                    to: 1
                    target: mainItemRoot
                }

                onClicked: {
                    // when clicked inside this area and outside the applications grid or any cool buttons, register it as if the user wanted to get out of the menu
                    root.toggle();
                }

                Rectangle{
                    anchors.fill: parent
                    color: colorWithAlpha(theme.backgroundColor, alphaValue)
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




                KCoreAddons.KUser { // this is needed for the greeting message (saying hello to the whatever name the user has)
                    id: kuser
                }

                PlasmaComponents.TextField { //searchbar
                    id: searchField

                    anchors {
                        top: parent.top
                        topMargin: units.iconSizes.large
                        horizontalCenter: parent.horizontalCenter
                    }
                    width: widthScreen

                    property string greetingMessage: plasmoid.configuration.greetingText

                    font.pointSize: 20
                    placeholderText: plasmoid.configuration.writeSomething ? plasmoid.configuration.greetingText : "Howdy, " + kuser.loginName + "! Type to start searching..."
                    //placeholderTextColor: colorWithAlpha(PlasmaCore.Theme.headerTextColor, 0.8)
                    horizontalAlignment: TextInput.AlignHCenter

                    onTextChanged: { // start searching
                        runnerModel.query = text
                    }

                    style: TextFieldStyle {

                        placeholderTextColor: colorWithAlpha(PlasmaCore.Theme.headerTextColor, 0.8)

                        background: Rectangle {
                            color: "transparent"
                        }

                    }

                    //searchField.background.color: "transparent"

                    //background: Rectangle {
                        //color: "transparent"
                    //}

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
                        color: "transparent" //  use "red" to see real dimensions and limits
                        anchors {
                            top: searchField.bottom
                            topMargin: units.iconSizes.medium
                            bottom: sessionControlBar.top
                            bottomMargin: units.iconSizes.medium
                            left: parent.left
                            leftMargin: Math.floor(0.05 * parent.width)
                        }

                        ItemGridView { // this is the grid in which we will store the favorites list
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

                        PlasmaCore.SvgItem { // nice line to separate favorites between all applications
                            id: horizontalSeparator
                            visible: showFavoritesInGrid && !searching
                            height: (showFavoritesInGrid && !searching) ? PlasmaCore.Units.devicePixelRatio * 4 : 0
                            width: Math.round(widthScreen * 0.75)
                            elementId: "horizontal-line"
                            z: 1

                            anchors {
                                horizontalCenter: parent.horizontalCenter // center
                                top: myFavorites.bottom // under the favorites menu button
                                topMargin: (showFavoritesInGrid && !searching) ? units.iconSizes.smallMedium : undefined // leave some space to make everything beautiful
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

                            onCurrentItemChanged: { // I don't really understand how this function works, but it's there and apparently does something (I didn't write this one)
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
                                height: (!showFavoritesInGrid || searching) ? rows * cellSize : (rows - 1) * cellSize // be extremely careful not to overlap the applications grid with the favorites grid! If such grid is present, then this grid needs to have its row count diminshed by 1 to make room for the favorites grid

                                property Item itemGrid: appsGrid
                                focus: true

                                ItemGridView { // this is actually the applications grid
                                    id: appsGrid
                                    visible: model.count > 0
                                    anchors.fill: parent

                                    cellWidth:  cellSize
                                    cellHeight: cellSize

                                    verticalScrollBarPolicy: Qt.ScrollBarAlwaysOff // it will look much better without scrollbars (also for some reason it destroys the layout if enabled by making this grid's width much bigger)

                                    dragEnabled: (index == 0)

                                    model: searching ? runnerModel.modelForRow(0) : rootModel.modelForRow(0).modelForRow(1) // if we happen to be searching, then we must show the results of said search. Else, we will default to showing all the applications

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

                                    onModelChanged: { // when we stop searching or start searching, highlight the first item just to give the user a hint that pressing "Enter" will launch the first entry.
                                        currentIndex = 0
                                        itemGrid.tryActivate(0, 0);
                                    }
                                }
                            }
                        }
                    }



                    ListModel {
                        id: categoriesModel
                    }

                    Component {
                        id: delegateListElement

                        Rectangle {
                            property int indexInModel: categoryIndex
                            property string iconName: categoryIcon

                            color: "transparent"
                            height: Math.floor(heightScreen / 12) // arbitrary placeholder value
                            width: Math.floor(widthScreen / 8)

                            PlasmaComponents.Label {
                                id: categoryTextId
                                text: categoryText
                                font.pointSize: 15
                                visible: showCategoriesText || showCategoriesIconAndText
                                anchors {
                                    right: (showCategoriesIcon || showCategoriesIconAndText) ? categoryIconId.left : parent.right
                                    left: parent.left
                                    verticalCenter: parent.verticalCenter
                                    leftMargin: highlightItemSvg.margins.left
                                    rightMargin: highlightItemSvg.margins.right
                                }

                                // collapsing text when the going gets tough
                                elide: Text.ElideRight
                                wrapMode: Text.NoWrap

                            }

                            PlasmaCore.IconItem {
                                id: categoryIconId
                                source: categoryIcon
                                visible: showCategoriesIcon || showCategoriesIconAndText

                                anchors {
                                    left: parent.contentItem
                                    right: parent.right
                                    rightMargin: highlightItemSvg.margins.right
                                    verticalCenter: parent.verticalCenter
                                }

                            }



                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    if (indexInModel > 0) { // show the category determined by indexInModel
                                        pageList.currentItem.itemGrid.model = rootModel.modelForRow(indexInModel).modelForRow(0)
                                    } else { // show All Applications
                                        if (indexInModel == 0) {
                                            pageList.currentItem.itemGrid.model = rootModel.modelForRow(0).modelForRow(1)
                                        }
                                        else { // show Favorites
                                            pageList.currentItem.itemGrid.model = rootModel.modelForRow(0).modelForRow(0)
                                        }
                                    }
                                    categoriesList.currentIndex = index
                                }

                                //onEntered: {
                                    //console.log("Entraste a", categoryText)
                                //}

                                //onExited: {
                                    //console.log("Saliste de", categoryText)
                                //}

                            }

                        }

                    }



                    PlasmaExtras.ScrollArea { // dedicated to storing the categories list

                        id: categoriesItem
                        height: heightScreen

                        ListView {

                            id: categoriesList
                            anchors.fill: parent
                            model: categoriesModel
                            delegate: delegateListElement
                            focus: true
                            // only add some fancy spacing between the buttons if they are only icons.
                            spacing: (showCategoriesText || showCategoriesIconAndText) ? 0 : units.iconSizes.small

                            // the following lines help maintaining consistency in highlighting with respect to whatever you have set in your Plasma Style. (This is taken from ItemGridDelegate.qml)
                            // TODO: it would be cool if some highlighting clues would be given to the user when some other category is hovered.
                            highlight: PlasmaComponents.Highlight {}
                            highlightFollowsCurrentItem: true
                            highlightMoveDuration: 0

                        }



                        anchors {
                            left: appsRectangle.right
                            leftMargin: units.iconSizes.medium
                            verticalCenter: parent.verticalCenter
                        }
                    }



                PlasmaCore.DataSource { // courtesy of https://github.com/varlesh/org.kde.plasma.compact-shutdown/blob/main/contents/ui/main.qml (I just copy+pasted it, some day I'll figure how this works)
                    id: executable
                    engine: "executable"
                    connectedSources: []
                    onNewData: disconnectSource(sourceName)

                    function exec(cmd) {
                        executable.connectSource(cmd)
                    }
                }

                RowLayout { // display session management buttons in a row

                    id: sessionControlBar
                    spacing: units.iconSizes.medium // arbitrary spacing between buttons whose value is non-arbitrary (it's taken from KDE Plasma's API so I trust they will work on other displays)

                    // The following SessionButtons are defined in SessionButton.qml. They are basically Buttons taken from the PlasmaComponents library with some values that will always be present - thus, I just put them in a separate qml file to avoid repeating lines of code.
                    SessionButton { // Shutdown Button
                        iconUrl: "system-shutdown"
                        onClicked: {
                            root.toggle() // make sure we hide this application prior to showing the fullscreen leave menu (or leave, this will depend on whether or not the user has set in its settings to skip the fullscreen leave menu)
                            executable.exec('qdbus org.kde.ksmserver /KSMServer logout -1 2 2')
                        }
                    }

                    SessionButton { // Restart Button
                        iconUrl: "system-reboot"
                        onClicked: {
                            root.toggle() // make sure we hide this application prior to showing the fullscreen leave menu (or leave, this will depend on whether or not the user has set in its settings to skip the fullscreen leave menu)
                            executable.exec('qdbus org.kde.ksmserver /KSMServer logout -1 1 2')
                        }
                    }

                    SessionButton { // Logout Button
                        iconUrl: "system-log-out"
                        onClicked: {
                            root.toggle() // make sure we hide this application prior to showing the fullscreen leave menu (or leave, this will depend on whether or not the user has set in its settings to skip the fullscreen leave menu)
                            executable.exec('qdbus org.kde.ksmserver /KSMServer logout -1 0 2')
                        }
                    }

                    SessionButton { // Lock Screen Button
                        iconUrl: "system-lock-screen"
                        onClicked: {
                            root.toggle() // make sure we hide this application prior to showing the fullscreen leave menu (or leave, this will depend on whether or not the user has set in its settings to skip the fullscreen leave menu)
                            executable.exec('qdbus org.freedesktop.ScreenSaver /ScreenSaver Lock')

                        }
                    }

                    anchors {
                        bottom: parent.bottom // RowLayout will be at the bottom-most part of the grid
                        bottomMargin: units.iconSizes.smallMedium // keep some nice distance towards the edge of the screen to not make it look out of place
                        horizontalCenter: parent.horizontalCenter // center the entire row
                    }
                }


            }
        }

    Component.onCompleted: {
        rootModel.pageSize = -1 // this will, somehow, make it show everything -- again, don't ask me!
        //console.log(systemFavorites.count)
        kicker.reset.connect(reset);
    }
}

