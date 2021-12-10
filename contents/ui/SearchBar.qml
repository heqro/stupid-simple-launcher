import QtQuick 2.4

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

// for using TextFieldStyle
import QtQuick.Controls.Styles 1.4

// user information is called by using this
import org.kde.kcoreaddons 1.0 as KCoreAddons

PlasmaComponents.TextField { //searchbar

    property string myText: text

    property bool noDesignChosen: plasmoid.configuration.searchBarNoDesign
    property bool underlineDesign: plasmoid.configuration.searchBarUnderline

    KCoreAddons.KUser { // this is needed for the greeting message (saying hello whatever the user name is)
        id: kuser
    }

    anchors {
        top: parent.top
        topMargin: units.iconSizes.large
        horizontalCenter: parent.horizontalCenter
    }
    width: widthScreen

    property string greetingMessage: plasmoid.configuration.greetingText

    font.pointSize: 20
    placeholderText: plasmoid.configuration.writeSomething ? plasmoid.configuration.greetingText : "Howdy, " + kuser.loginName + "! Type to start searching..."
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

    Loader {
        active: !noDesignChosen
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.bottom
        }

        source: underlineDesign ? "searchbar_designs/Underlining.qml" : ""
    }
}
