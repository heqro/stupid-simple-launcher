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

    property bool showToolTip: (categoryTextId.truncated || showCategoriesIcon) && showCategoriesTooltip

    // customization options set from ConfigGeneral.qml
    property bool customizeCategoriesFontSize: plasmoid.configuration.customizeCategoriesFontSize
    property int categoriesFontSize: plasmoid.configuration.categoriesFontSize

    property bool isButtonSizeSet: plasmoid.configuration.customizeCategoriesButtonSize

    property bool attemptedToChangeCategory: false

    color: "transparent"

    height: isButtonSizeSet ? plasmoid.configuration.categoriesButtonHeight : t_metrics.height * 2

    width:  isButtonSizeSet ? plasmoid.configuration.categoriesButtonWidth : t_metrics.width + 4 * units.smallSpacing

    opacity: (!searching && (categoriesList.currentIndex == index || mouseArea.containsMouse)) ? 1 : 0.4

    TextMetrics {
        id: t_metrics
        text: "Toutes les applications" // long-ass text for making sure most languages will have their applications tag visible out of the box.
        font.pointSize: theme.defaultFont.pointSize * 1.2
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
            font.pointSize: customizeCategoriesFontSize ? categoriesFontSize : theme.defaultFont.pointSize * 1.2
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
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            if (searching)
                return
            attemptedToChangeCategory = true
            categoriesList.currentIndex = index // highlight current category to give the feeling of responsiveness.
        }

        onEntered: { // show tooltips if the user wanted to.
            if (showToolTip) {
                toolTip.showToolTip()
            }
        }

        onExited: { // immediately hide tooltips if the user wanted them to be shown.
            if (showToolTip) {
                toolTip.hideToolTip()
            }

        }
    }
}
