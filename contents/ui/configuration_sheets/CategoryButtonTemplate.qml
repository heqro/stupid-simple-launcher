// CategoryButtonTemplate.qml - this file creates a generic category button that we can use as a mold for both the categories sidebar as well as the draggable category found in the configuration options.

// TODO - make CategoryButton.qml extend this file just like ConfigCategory.qml currently does to avoid code repetition.

import QtQuick 2.4

// communicating with plasmoid options so as to customize the sidebar from this module
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
// for using the button itself
import org.kde.plasma.components 2.0 as PlasmaComponents
// for using RowLayout
import QtQuick.Layouts 1.1

Rectangle { // rectangle used for marking the bounds for the category button

    id: myCategoryTemplate

    property string iconName: "emblem-favorite"
    property string categoryName: i18n("I am a category. Customize my size!")

    // deletthis
    property bool showCategoriesIcon: plasmoid.configuration.categoriesIcon
    property bool showCategoriesText: plasmoid.configuration.categoriesText
    property bool showCategoriesIconAndText: plasmoid.configuration.categoriesIconAndText

    property bool showCategoriesTooltip: true

    property bool isSidebarOnTheRight: plasmoid.configuration.showCategoriesOnTheRight
    // fin deletthis


    property bool showToolTip: (categoryTextId.truncated || showCategoriesIcon) && showCategoriesTooltip

    // customization options set from ConfigGeneral.qml
    property bool isCategoriesFontSizeSet: plasmoid.configuration.customizeCategoriesFontSize
    property int fontSize: isCategoriesFontSizeSet ? plasmoid.configuration.categoriesFontSize : parent.height

    height: myCategoryTemplateList.buttonHeight
    width:  myCategoryTemplateList.buttonWidth

    color: "transparent"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 2 * units.smallSpacing
        anchors.rightMargin: 2 * units.smallSpacing

        layoutDirection: isSidebarOnTheRight ? Qt.RightToLeft : Qt.LeftToRight

        PlasmaCore.IconItem { // category icon
            id: categoryIconId
            source: iconName
            visible: showCategoriesIcon || showCategoriesIconAndText

            // arbitrary values because some icon packs cannot behave properly and need to be scaled down.
            Layout.preferredHeight: Math.floor(11 * parent.height / 13)
            Layout.preferredWidth: Math.floor(11 * parent.height / 13)
            Layout.alignment: Qt.AlignVCenter
        }

        PlasmaComponents.Label { // label showing the category name
            id: categoryTextId
            text: categoryName
            font.pointSize: isCategoriesFontSizeSet ? fontSize : Math.min(parent.height, PlasmaCore.Theme.defaultFont.pointSize * 1.2)
//             font.pointSize: customizeCategoriesFontSize ? fontSize : Math.floor(PlasmaCore.Theme.defaultFont.pointSize * 1.2)
            minimumPointSize: parent.height
            visible: showCategoriesText || showCategoriesIconAndText

            Layout.fillHeight: true
            Layout.fillWidth: true
            fontSizeMode: Text.VerticalFit
//             Layout.alignment: Qt.AlignVCenter
            PlasmaCore.ToolTipArea {
                id: toolTip
                mainText: categoryName
            }

            // collapsing text when the going gets tough
            elide: Text.ElideRight
            wrapMode: Text.NoWrap

        }
    }
}
