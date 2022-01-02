import QtQuick 2.4

// communicating with plasmoid options so as to customize the sidebar from this module
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
// for using the button itself
import org.kde.plasma.components 2.0 as PlasmaComponents
// for using RowLayout
import QtQuick.Layouts 1.1

Rectangle { // rectangle used for marking the bounds for the category button

    id: containerForCategory

    property int indexInModel: categoryIndex
    property string iconName: categoryIcon
    property string categoryName: categoryText
    property int selectedItemIndex: categoriesList.currentIndex

    property bool showToolTip: (categoryTextId.truncated || showCategoriesIcon) && showCategoriesTooltip

    // customization options set from ConfigGeneral.qml
    property bool customizeCategoriesFontSize: plasmoid.configuration.customizeCategoriesFontSize
    property int categoriesFontSize: plasmoid.configuration.categoriesFontSize

    property bool isButtonSizeSet: plasmoid.configuration.customizeCategoriesButtonSize

    color: "transparent"
//     height: units.iconSizes.huge
    height: isButtonSizeSet ? plasmoid.configuration.categoriesButtonHeight : units.iconSizes.huge
//     width:  isButtonSizeSet ? Math.min(plasmoid.configuration.categoriesButtonWidth, Math.floor(widthScreen / 8) : units.iconSizes.huge * 32
    width:  isButtonSizeSet ? plasmoid.configuration.categoriesButtonWidth : Math.floor(widthScreen / 8)


//     width: height * 32
    //width: (showCategoriesText || showCategoriesIconAndText) ? Math.floor(widthScreen / 8) : height

    opacity: (categoriesList.currentIndex == index && !searching) ? 1 : 0.4

    onSelectedItemIndexChanged: {
        opacity = (categoriesList.currentIndex == index && !searching) ? 1 : 0.4
    }

    RowLayout {
        anchors.fill: parent
//         anchors.leftMargin: highlightItemSvg.margins.left
        anchors.leftMargin: 2 * units.smallSpacing
//         anchors.rightMargin: highlightItemSvg.margins.right
        anchors.rightMargin: 2 * units.smallSpacing

        layoutDirection: showCategoriesOnTheRight ? Qt.RightToLeft : Qt.LeftToRight

        PlasmaCore.IconItem { // category icon
            id: categoryIconId
            source: categoryIcon
            visible: showCategoriesIcon || showCategoriesIconAndText

            // arbitrary values because some icon packs cannot behave properly and need to be scaled down.
            Layout.preferredHeight: Math.floor(4 * parent.height / 5)
            Layout.preferredWidth: Math.floor(4 * parent.height / 5)
        }

        PlasmaComponents.Label { // label showing the category name
            id: categoryTextId
            text: categoryName

            // Using font sizes that are consistent with plasma
            font.pointSize: customizeCategoriesFontSize ? categoriesFontSize : PlasmaCore.Theme.defaultFont.pointSize * 1.2
            //font.pointSize: customizeCategoriesFontSize ? categoriesFontSize : Math.min(containerForCategory.height, PlasmaCore.Theme.defaultFont.pointSize * 1.2)
            minimumPointSize: containerForCategory.height

            visible: showCategoriesText || showCategoriesIconAndText
            Layout.preferredHeight: parent.height
            Layout.fillWidth: true
            fontSizeMode: Text.VerticalFit
            PlasmaCore.ToolTipArea { // for showing the tooltip linked to this category's name
                id: toolTip
                mainText: categoryText
            }

            // collapsing text when the going gets tough
            elide: Text.ElideRight
            wrapMode: Text.NoWrap

        }


    }

    MouseArea { // I am using this MouseArea to recreate how a button would behave (just using Buttons didn't entirely work the way I intended.)
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            if (searching) {
                return
            }
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
            //                                     containerForCategory.opacity = 1
        }

        onEntered: { // highlight item on hovering
            if (categoriesList.currentIndex != index && !searching) {
                containerForCategory.opacity = 0.9
            }
            if (showToolTip) {
                toolTip.showToolTip()
            }


        }

        onExited: { // reduce opacity on leaving
            if (categoriesList.currentIndex != index && !searching) {
                containerForCategory.opacity = 0.4
            }
            if (showToolTip) {
                toolTip.hideToolTip()
            }

        }
    }
}
