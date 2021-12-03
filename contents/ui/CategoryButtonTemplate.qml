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

    //property int indexInModel: categoryIndex
    property string iconName: "emblem-favorite"
    property string categoryName: i18n("I am a category. Customize my size!")
//     property int selectedItemIndex: categoriesList.currentIndex

    // deletthis
    property bool showCategoriesIcon: plasmoid.configuration.categoriesIcon
    property bool showCategoriesText: plasmoid.configuration.categoriesText
    property bool showCategoriesIconAndText: plasmoid.configuration.categoriesIconAndText

    property bool showCategoriesTooltip: true

    property bool showCategoriesOnTheRight: plasmoid.configuration.showCategoriesOnTheRight
    // fin deletthis


    property bool showToolTip: (categoryTextId.truncated || showCategoriesIcon) && showCategoriesTooltip

    // customization options set from ConfigGeneral.qml
    property bool customizeCategoriesFontSize: plasmoid.configuration.customizeCategoriesFontSize
    property int categoriesFontSize: customizeCategoriesFontSize ? plasmoid.configuration.categoriesFontSize : parent.height

    property bool isButtonSizeSet: plasmoid.configuration.customizeCategoriesButtonSize
    property int buttonHeight: plasmoid.configuration.categoriesButtonHeight
    property int buttonWidth: plasmoid.configuration.categoriesButtonWidth


    color: "transparent"
    height: isButtonSizeSet ? buttonHeight : units.iconSizes.huge
    width:  isButtonSizeSet ? buttonWidth : 320
    //     width: (showCategoriesText || showCategoriesIconAndText) ? Math.floor(widthScreen / 8) : height

    RowLayout {
        anchors.fill: parent
        //         anchors.leftMargin: highlightItemSvg.margins.left
        anchors.leftMargin: 2 * units.smallSpacing
        //         anchors.rightMargin: highlightItemSvg.margins.right
        anchors.rightMargin: 2 * units.smallSpacing

        layoutDirection: showCategoriesOnTheRight ? Qt.RightToLeft : Qt.LeftToRight

        PlasmaCore.IconItem { // category icon
            id: categoryIconId
            source: iconName
            visible: showCategoriesIcon || showCategoriesIconAndText

            // arbitrary values because some icon packs cannot behave properly and need to be scaled down.
            Layout.preferredHeight: Math.floor(11 * parent.height / 13)
            Layout.preferredWidth: Math.floor(11 * parent.height / 13)
        }

        PlasmaComponents.Label { // label showing the category name
            id: categoryTextId
            text: categoryName
//             font.pointSize: customizeCategoriesFontSize ? categoriesFontSize : myCategoryTemplate.height
            font.pointSize: categoriesFontSize
            minimumPointSize: 15
            visible: showCategoriesText || showCategoriesIconAndText
            Layout.fillHeight: true
            Layout.fillWidth: true
            fontSizeMode: Text.VerticalFit
            PlasmaCore.ToolTipArea {
                id: toolTip
                mainText: categoryName
            }

            // collapsing text when the going gets tough
            elide: Text.ElideRight
            wrapMode: Text.NoWrap

        }


    }

    //MouseArea {
        //anchors.fill: parent
        //hoverEnabled: true
        //onClicked: {
            //if (searching) {
                //return
            //}
            //if (indexInModel > 0) { // show the category determined by indexInModel
                //pageList.currentItem.itemGrid.model = rootModel.modelForRow(indexInModel).modelForRow(0)
            //} else { // show All Applications
                //if (indexInModel == 0) {
                    //pageList.currentItem.itemGrid.model = rootModel.modelForRow(0).modelForRow(1)
                //}
                //else { // show Favorites
                    //pageList.currentItem.itemGrid.model = rootModel.modelForRow(0).modelForRow(0)
                //}
            //}
            //categoriesList.currentIndex = index
                                                //myCategoryTemplate.opacity = 1
        //}

        //onEntered: { // highlight item on hovering
            //if (categoriesList.currentIndex != index && !searching) {
                //myCategoryTemplate.opacity = 0.9
            //}
            //if (showToolTip) {
                //toolTip.showToolTip()
            //}


        //}

        //onExited: { // reduce opacity on leaving
            //if (categoriesList.currentIndex != index && !searching) {
                //myCategoryTemplate.opacity = 0.4
            //}
            //if (showToolTip) {
                //toolTip.hideToolTip()
            //}

        //}
    //}
}
