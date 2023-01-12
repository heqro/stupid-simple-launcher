// it won't work with any lower version (silent error)
import QtQuick 2.4

import org.kde.plasma.core 2.0 as PlasmaCore
// for using the button itself
import org.kde.plasma.components 2.0 as PlasmaComponents

// for using RowLayout
import QtQuick.Layouts 1.1


Item {

    id: containerForCategory

    // appsGridModelKey is communicated to the applications grid to change the currently shown category. It's an index that may correspond to rootModel's index or may not (for example, when we want to show recent apps, recent docs or favorites).
    property int appsGridModelKey
    required property string categoryName

    // font size related properties
    required property bool customizeCategoriesFontSize
    property int categoriesFontSize

    // button size related properties
    required property int buttonHeight
    required property int buttonWidth

    // design related properties
    required property bool showCategoriesIcon
    required property bool showCategoriesText
    required property bool showCategoriesIconAndText
    required property bool showCategoriesOnTheRight

    // behavior related properties
    required property bool showCategoriesTooltip

    // properties related to the list with the rest of the buttons
    property int categoriesListCurrentIndex
    property int indexInCategoriesList

    height: visible ? buttonHeight : 0
    width:  buttonWidth

    opacity: categoriesListCurrentIndex == indexInCategoriesList || mouseArea.containsMouse ? 1 : 0.4

    signal changeCategoryRequested(int appsGridModelKey, int indexInCategoriesList)

    Row {

        id: rowLayout

        anchors {
            fill: parent
            leftMargin: units.largeSpacing
            rightMargin: units.largeSpacing
            topMargin: visible && showCategoriesIcon ? units.smallSpacing : 0
            bottomMargin: visible && showCategoriesIcon ? units.smallSpacing : 0
        }

        layoutDirection: showCategoriesOnTheRight ? Qt.RightToLeft : Qt.LeftToRight

        spacing: units.mediumSpacing

        PlasmaCore.IconItem {
            id: categoryIconId
            height: Math.floor(4 * parent.height / 5)
            width: Math.floor(4 * parent.height / 5)
            visible: showCategoriesIcon || showCategoriesIconAndText
            anchors.verticalCenter: parent.verticalCenter
        }

        PlasmaComponents.Label { // label showing the category name
            id: categoryTextId
            text: categoryName

            // Using font sizes that are consistent with plasma
            font.pointSize: customizeCategoriesFontSize ? categoriesFontSize : theme.defaultFont.pointSize * 1.2
            minimumPointSize: containerForCategory.height

            visible: showCategoriesText || showCategoriesIconAndText
            height: parent.height
            width: parent.width - categoryIconId.width
            anchors.verticalCenter: parent.verticalCenter
            fontSizeMode: Text.VerticalFit

            PlasmaCore.ToolTipArea { // for showing the tooltip linked to this category's name
                id: toolTip
                mainText: categoryName
                active: (categoryTextId.truncated || showCategoriesIcon) && showCategoriesTooltip
            }

            // collapsing text when needed
            elide: Text.ElideRight
            wrapMode: Text.NoWrap
        }


    }

    MouseArea { // I am using this MouseArea to recreate how a button would behave (just using Buttons didn't entirely work the way I intended.)
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: changeCategoryRequested(appsGridModelKey, indexInCategoriesList)

        onEntered: { // show tooltips if the user wanted to.
            toolTip.showToolTip()
        }

        onExited: { // immediately hide tooltips if the user wanted them to be shown.
            toolTip.hideToolTip()
        }
    }

    function setSourceIcon(source) {
        categoryIconId.source = source
    }

    // Debugging functions

    function isTooltipActive() {
        return toolTip.active
    }

    function isIconVisible() {
        return categoryIconId.visible
    }

    function isTextVisible() {
        return categoryTextId.visible
    }

    function getLayoutDirection() {
        return rowLayout.layoutDirection
    }
}
