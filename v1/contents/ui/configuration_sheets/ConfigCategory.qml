import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons
import org.kde.draganddrop 2.0 as DragDrop

import org.kde.plasma.private.kicker 0.1 as Kicker

import ".."

Item {
    id: configCategory

    property alias cfg_categoriesText: categoriesShowTextCheckbox.checked
    property alias cfg_categoriesIcon: categoriesShowIconCheckbox.checked
    property alias cfg_categoriesIconAndText: categoriesShowTextAndIconCheckbox.checked

    property alias cfg_showCategoriesTooltip: categoriesTooltip.checked

    property alias cfg_showCategories: showCategories.checked

    property alias cfg_showCategoriesOnTheRight: categoriesOnTheRight.checked

    property alias cfg_customizeCategoriesFontSize: customizeCategoriesFontSizeCheckbox.checked
    property alias cfg_categoriesFontSize: categoriesFontSizeSpinbox.value

    property alias cfg_customizeCategoriesButtonSize: customizeCategoriesSize.checked
    property alias cfg_categoriesButtonHeight: myCategoryTemplate.height
    property alias cfg_categoriesButtonWidth: myCategoryTemplate.width

    property alias cfg_showFavoritesCategory: showFavoritesCategory.checked
    property alias cfg_showRecentFilesCategory: showRecentFilesCategory.checked
    property alias cfg_showRecentAppsCategory: showRecentAppsCategory.checked

    Column {
        spacing: units.smallSpacing
        anchors.horizontalCenter: parent.horizontalCenter
        CheckBox {
            id: showCategories
            text: i18n("Show the categories sidebar")
        }

        PlasmaExtras.Heading {
            text: "Appearance"
            visible: showCategories.checked
        }

        CheckBox {
            id: categoriesOnTheRight
            visible: showCategories.checked
            text: i18n("Show the categories sidebar at the right side of the menu")
        }

        GroupBox {

            visible: showCategories.checked
            ExclusiveGroup { id: categoriesCustomizationGroup}

            Column {
                RadioButton {
                    id: categoriesShowTextCheckbox
                    text: i18n("Show categories' names only")
                    exclusiveGroup: categoriesCustomizationGroup
                }

                RadioButton {
                    id: categoriesShowIconCheckbox
                    text: i18n("Show categories' icons only")
                    exclusiveGroup: categoriesCustomizationGroup
                }

                RadioButton {
                    id: categoriesShowTextAndIconCheckbox
                    text: i18n("Show categories' icons and names")
                    checked: true
                    exclusiveGroup: categoriesCustomizationGroup
                }
            }
        }

        Row {
            visible: showCategories.checked && (categoriesShowTextCheckbox.checked || categoriesShowTextAndIconCheckbox.checked)

            CheckBox {
                id: customizeCategoriesFontSizeCheckbox
                text: i18n("Customize categories' font size")
            }

            SpinBox {
                id: categoriesFontSizeSpinbox
                minimumValue: 4
                maximumValue: 128
                stepSize: 1
                enabled: customizeCategoriesFontSizeCheckbox.checked
            }
        }

        CheckBox {
            id: customizeCategoriesSize
            text: i18n("Customize categories' size")
            visible: showCategories.checked
        }

        Item { // artificial spacer
            width: 1
            height: units.smallSpacing * 2
        }

        CategoryButton {
            id: myCategoryTemplate
            readonly property int rulersSize: units.iconSizes.small

            categoryName: "I am a category. Customize my size"

            customizeCategoriesFontSize: customizeCategoriesFontSizeCheckbox.checked
            categoriesFontSize: categoriesFontSizeSpinbox.value

            buttonHeight: plasmoid.configuration.categoriesButtonHeight
            buttonWidth: plasmoid.configuration.categoriesButtonWidth
            visible: showCategories.checked && customizeCategoriesSize.checked

            showCategoriesIcon: categoriesShowIconCheckbox.checked
            showCategoriesText: categoriesShowTextCheckbox.checked
            showCategoriesIconAndText: categoriesShowTextAndIconCheckbox.checked
            showCategoriesOnTheRight: categoriesOnTheRight.checked

            showCategoriesTooltip: categoriesTooltip.checked

            Rectangle {
                width: parent.rulersSize
                height: parent.rulersSize
                radius: parent.rulersSize
                color: theme.highlightColor
                anchors.horizontalCenter: parent.right
                anchors.verticalCenter: parent.verticalCenter

                MouseArea {
                    readonly property int minimumWidth: units.iconSizes.huge
                    anchors.fill: parent
                    drag { target: parent; axis: Drag.XAxis }
                    onMouseXChanged: {
                        if (drag.active && validWidthRequested(mouseX)) {
                            myCategoryTemplate.width = myCategoryTemplate.width + mouseX
                        }
                    }

                    function validWidthRequested(variation) {
                        return myCategoryTemplate.width + variation >= minimumWidth
                    }
                }
            }

            Rectangle {
                width:  parent.rulersSize
                height: parent.rulersSize
                radius: parent.rulersSize
                color: theme.highlightColor
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.bottom

                MouseArea {
                    readonly property int minimumHeight: units.iconSizes.smallMedium
                    anchors.fill: parent
                    drag { target: parent; axis: Drag.YAxis }
                    onMouseYChanged: {
                        if (drag.active && validHeightRequested(mouseY)) {
                            myCategoryTemplate.height = myCategoryTemplate.height + mouseY
                        }
                    }

                    function validHeightRequested(variation) {
                        return myCategoryTemplate.height + variation >= minimumHeight
                    }
                }
            }

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                radius: units.smallSpacing
                border.color: theme.highlightColor
                border.width: Math.floor(units.smallSpacing / 2)
            }

            Component.onCompleted: {
                setSourceIcon("emblem-favorite")
            }
        }

        Item { // artificial spacer
            width: 1
            height: units.smallSpacing * 2
        }

        PlasmaExtras.Heading {
            text: "Behavior"
            visible: showCategories.checked
        }

        CheckBox {
            visible: showCategories.checked
            id: categoriesTooltip
            text: i18n("Show tooltip on hover")
        }

        PlasmaExtras.Heading {
            text: "Extra categories"
            visible: showCategories.checked
        }

        Column {
            visible: showCategories.checked

            CheckBox {
                id: showFavoritesCategory
                text: i18n("Show Favorites")
            }

            CheckBox {
                id: showRecentFilesCategory
                text: i18n("Show Recent Files")
            }

            CheckBox {
                id: showRecentAppsCategory
                text: i18n("Show Recent Applications")
            }
        }
    }
}
