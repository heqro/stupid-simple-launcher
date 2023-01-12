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

    //width: childrenRect.width
    //height: childrenRect.height

    property alias cfg_categoriesText: categoriesShowTextCheckbox.checked
    property alias cfg_categoriesIcon: categoriesShowIconCheckbox.checked
    property alias cfg_categoriesIconAndText: categoriesShowTextAndIconCheckbox.checked

    property alias cfg_showCategoriesTooltip: categoriesTooltip.checked

    property alias cfg_showCategories: showCategories.checked

    property alias cfg_showCategoriesOnTheRight: categoriesOnTheRight.checked

    property alias cfg_customizeCategoriesFontSize: customizeCategoriesFontSizeCheckbox.checked
    property alias cfg_categoriesFontSize: categoriesFontSizeSpinbox.value

    property alias cfg_customizeCategoriesButtonSize: customizeCategoriesSize.checked
    property alias cfg_categoriesButtonHeight: myCategoryTemplateList.delegateButtonHeight
    property alias cfg_categoriesButtonWidth: myCategoryTemplateList.delegateButtonWidth

    property alias cfg_showFavoritesCategory: showFavoritesCategory.checked
    property alias cfg_showRecentFilesCategory: showRecentFilesCategory.checked
    property alias cfg_showRecentAppsCategory: showRecentAppsCategory.checked

    ColumnLayout {
        RowLayout {
            Layout.fillWidth: true

            ColumnLayout {

                // if I don't use QtQuick Controls 1.0 this whole thing crashes.
                // As a consequence, I have to use ExclusiveGroup as defined in
                // https://doc.qt.io/qt-5/qml-qtquick-controls-radiobutton.html#details

                RowLayout {
                    Layout.fillWidth: true
                    CheckBox {
                        Layout.leftMargin: units.smallSpacing
                        id: showCategories
                        text: i18n("Show the categories sidebar")
                    }
                }

                PlasmaExtras.Heading {
                    text: "Appearance"
                    visible: showCategories.checked
                }

                RowLayout {
                    Layout.fillWidth: true
                    visible: showCategories.checked
                    CheckBox {
                        Layout.leftMargin: units.smallSpacing
                        id: categoriesOnTheRight
                        text: i18n("Show the categories sidebar at the right side of the menu")
                    }
                }

                GroupBox {

                    visible: showCategories.checked
                    ExclusiveGroup { id: categoriesCustomizationGroup}

                    ColumnLayout {
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

                RowLayout {
                    Layout.fillWidth: true
                    visible: showCategories.checked && (categoriesShowTextCheckbox.checked || categoriesShowTextAndIconCheckbox.checked)

                    CheckBox {
                        Layout.leftMargin: units.smallSpacing
                        id: customizeCategoriesFontSizeCheckbox
                        text: i18n("Customize categories' font size")
                    }
                    SpinBox{
                        id: categoriesFontSizeSpinbox
                        minimumValue: 4
                        maximumValue: 128
                        stepSize: 1
                        enabled: customizeCategoriesFontSizeCheckbox.checked
                    }

                }

                RowLayout {
                    Layout.fillWidth: true

                    ColumnLayout {
                        Layout.fillWidth: true
                        CheckBox {
                            Layout.leftMargin: units.smallSpacing
                            id: customizeCategoriesSize
                            text: i18n("Customize categories' size")
                            visible: showCategories.checked
                            Layout.fillWidth: true
                        }

                        ListView {
                            id: myCategoryTemplateList
                            currentIndex: 0

                            Layout.fillWidth: true
                            Layout.minimumHeight: (plasmoid.configuration.categoriesButtonHeight > 0) ? contentHeight : 0


                            Layout.fillHeight: true
                            Layout.minimumWidth: (plasmoid.configuration.categoriesButtonWidth > 0) ? plasmoid.configuration.categoriesButtonWidth : units.iconSizes.huge
                            visible: showCategories.checked && customizeCategoriesSize.checked

                            property int delegateButtonWidth: width
                            property int delegateButtonHeight: height

                            highlight: PlasmaExtras.Highlight {}
                            highlightFollowsCurrentItem: true
                            highlightMoveDuration: 0

                            delegate: CategoryButton {

                                id: myCategoryTemplate

                                property int rulersSize: 18

                                categoryName: "I am a category. Customize my size"

                                customizeCategoriesFontSize: customizeCategoriesFontSizeCheckbox.checked
                                categoriesFontSize: categoriesFontSizeSpinbox.value

                                buttonHeight: myCategoryTemplateList.delegateButtonHeight
                                buttonWidth: myCategoryTemplateList.delegateButtonWidth

                                showCategoriesIcon: categoriesShowIconCheckbox.checked
                                showCategoriesText: categoriesShowTextCheckbox.checked
                                showCategoriesIconAndText: categoriesShowTextAndIconCheckbox.checked
                                showCategoriesOnTheRight: categoriesOnTheRight.checked

                                showCategoriesTooltip: categoriesTooltip.checked

                                MouseArea {
                                    property bool clicked: false
                                    anchors.fill: parent

                                    drag{
                                        target: parent
                                        minimumX: 0
                                        minimumY: 0
                                        maximumX: parent.parent.width - parent.width
                                        maximumY: parent.parent.height - parent.height
                                        smoothed: true
                                    }

                                    onClicked: {
                                        myCategoryTemplateList.currentIndex = (myCategoryTemplateList.currentIndex == 0) ? -1 : 0
                                    }
                                }

                                Rectangle {
                                    width: rulersSize
                                    height: rulersSize
                                    radius: rulersSize
                                    color: theme.highlightColor
                                    anchors.horizontalCenter: parent.right
                                    anchors.verticalCenter: parent.verticalCenter

                                    MouseArea {
                                        anchors.fill: parent
                                        drag{ target: parent; axis: Drag.XAxis }
                                        onMouseXChanged: {
                                            if(drag.active){
                                                if (myCategoryTemplate.width + mouseX < units.iconSizes.huge)
                                                    myCategoryTemplate.width = units.iconSizes.huge
                                                else
                                                    myCategoryTemplate.width = myCategoryTemplate.width + mouseX
                                                myCategoryTemplateList.delegateButtonWidth = myCategoryTemplate.width
                                            }
                                        }
                                    }
                                }
                                Rectangle {
                                    width: rulersSize
                                    height: rulersSize
                                    radius: rulersSize
//                                     x: parent.x / 2
                                    //y: parent.y
                                    color: theme.highlightColor
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.verticalCenter: parent.bottom

                                    MouseArea {
                                        anchors.fill: parent
                                        drag{ target: parent; axis: Drag.YAxis }
                                        onMouseYChanged: {
                                            if(drag.active){
                                                if(myCategoryTemplate.height + mouseY < units.iconSizes.huge)
                                                    myCategoryTemplate.height = units.iconSizes.huge
                                                else
                                                    myCategoryTemplate.height = myCategoryTemplate.height + mouseY
                                                myCategoryTemplateList.delegateButtonHeight = myCategoryTemplate.height
                                            }
                                        }
                                    }
                                }

                                Component.onCompleted: {
                                    setSourceIcon("emblem-favorite")
                                }
                            }
                            model: ListModel {
                                ListElement {}
                            }
                        }
                    }

                }

                PlasmaExtras.Heading {
                    text: "Behavior"
                    visible: showCategories.checked
                }

                RowLayout {
                    Layout.fillWidth: true
                    visible: showCategories.checked
                    CheckBox {
                        Layout.leftMargin: units.smallSpacing
                        id: categoriesTooltip
                        text: i18n("Show categories' names in a tooltip when the text is elided or when using icons-only menu")
                    }
                }

                PlasmaExtras.Heading {
                    text: "Extra categories"
                    visible: showCategories.checked
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    visible: showCategories.checked

                    CheckBox {
                        Layout.fillWidth: true
                        Layout.leftMargin: units.smallSpacing
                        id: showFavoritesCategory
                        text: i18n("Show the 'Favorites' category")
                    }

                    CheckBox {
                        Layout.fillWidth: true
                        Layout.leftMargin: units.smallSpacing
                        id: showRecentFilesCategory
                        text: i18n("Show the 'Recent Files' category")
                    }

                    CheckBox {
                        Layout.fillWidth: true
                        Layout.leftMargin: units.smallSpacing
                        id: showRecentAppsCategory
                        text: i18n("Show the 'Recent Applications' category")
                    }
                }


            }
        }
    }

}
