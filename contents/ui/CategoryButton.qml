import QtQuick 2.4
import org.kde.plasma.core 2.0 as PlasmaCore
// for using the button itself
import org.kde.plasma.components 2.0 as PlasmaComponents
// for using RowLayout
import QtQuick.Layouts 1.1

Rectangle { // rectangle used for marking the bounds for the category button

    id: containerForCategory

    property int indexInModel: categoryIndex
    property string iconName: categoryIcon
    property int selectedItemIndex: categoriesList.currentIndex

    property bool showToolTip: (categoryTextId.truncated || showCategoriesIcon) && showCategoriesTooltip

    color: "transparent"
    height: Math.floor(heightScreen / 12) // arbitrary placeholder value
    width: Math.floor(widthScreen / 8)

    opacity: (categoriesList.currentIndex == index && !searching) ? 1 : 0.4

    onSelectedItemIndexChanged: {
        opacity = (categoriesList.currentIndex == index && !searching) ? 1 : 0.4
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: highlightItemSvg.margins.left
        anchors.rightMargin: highlightItemSvg.margins.right

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
            text: categoryText
            font.pointSize: 15
            visible: showCategoriesText || showCategoriesIconAndText
            Layout.preferredHeight: parent.height
            Layout.fillWidth: true
            PlasmaCore.ToolTipArea {
                id: toolTip
                mainText: categoryText
            }

            // collapsing text when the going gets tough
            elide: Text.ElideRight
            wrapMode: Text.NoWrap

        }


    }





    MouseArea {
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
