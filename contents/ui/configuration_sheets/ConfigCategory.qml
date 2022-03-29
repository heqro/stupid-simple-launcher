import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.kirigami 2.5 as Kirigami

import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons
import org.kde.draganddrop 2.0 as DragDrop

import org.kde.plasma.private.kicker 0.1 as Kicker


Item {
    id: configCategory

    //width: childrenRect.width
    //height: childrenRect.height

    property alias cfg_categoriesText: categoriesShowText.checked
    property alias cfg_categoriesIcon: categoriesShowIcon.checked
    property alias cfg_categoriesIconAndText: categoriesShowTextAndIcon.checked

    property alias cfg_showCategoriesTooltip: showCategoriesTooltip.checked

    property alias cfg_showCategories: showCategories.checked

    property alias cfg_showCategoriesOnTheRight: showCategoriesOnTheRight.checked

    property alias cfg_customizeCategoriesFontSize: customizeCategoriesFontSize.checked
    property alias cfg_categoriesFontSize: categoriesFontSize.value

    property alias cfg_customizeCategoriesButtonSize: customizeCategoriesSize.checked
    property alias cfg_categoriesButtonHeight: myCategoryTemplateList.buttonHeight
    property alias cfg_categoriesButtonWidth: myCategoryTemplateList.buttonWidth

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
                }

                RowLayout {
                    Layout.fillWidth: true
                    visible: showCategories.checked
                    CheckBox {
                        Layout.leftMargin: units.smallSpacing
                        id: showCategoriesOnTheRight
                        text: i18n("Show the categories sidebar at the right side of the menu")
                    }
                }

                GroupBox {

                    visible: showCategories.checked
                    ExclusiveGroup { id: categoriesCustomizationGroup}

                    ColumnLayout {
                        RadioButton {
                            id: categoriesShowText
                            text: i18n("Show categories' names only")
                            checked: true
                            exclusiveGroup: categoriesCustomizationGroup
                        }

                        RadioButton {
                            id: categoriesShowIcon
                            text: i18n("Show categories' icons only (will misbehave with downloaded icons)")
                            exclusiveGroup: categoriesCustomizationGroup
                        }

                        RadioButton {
                            id: categoriesShowTextAndIcon
                            text: i18n("Show categories' icons and names")
                            exclusiveGroup: categoriesCustomizationGroup
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    visible: showCategories.checked && (categoriesShowText.checked || categoriesShowTextAndIcon.checked)

                    CheckBox {
                        Layout.leftMargin: units.smallSpacing
                        id: customizeCategoriesFontSize
                        text: i18n("Customize categories' font size")
                    }
                    SpinBox{
                        id: categoriesFontSize
                        minimumValue: 4
                        maximumValue: 128
                        stepSize: 1
                        enabled: customizeCategoriesFontSize.checked
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



//                             Layout.minimumHeight: (plasmoid.configuration.categoriesButtonHeight > 0) ? plasmoid.configuration.categoriesButtonHeight : units.iconSizes.smallMedium
                            visible: showCategories.checked && customizeCategoriesSize.checked

                            property int buttonWidth: width
                            property int buttonHeight: height

                            highlight: PlasmaComponents.Highlight {}
                            highlightFollowsCurrentItem: true
                            highlightMoveDuration: 0
                            delegate: CategoryButtonTemplate {
                                id: myCategoryTemplate
                                opacity: (currentIndex == 0) ? 1 : 0.4
                                property int rulersSize: 18
                                showCategoriesIcon: categoriesShowIcon.checked
                                showCategoriesText: categoriesShowText.checked
                                showCategoriesIconAndText: categoriesShowTextAndIcon.checked
                                isSidebarOnTheRight: showCategoriesOnTheRight.checked
                                isCategoriesFontSizeSet: customizeCategoriesFontSize.checked
                                fontSize: categoriesFontSize.value
                                MouseArea {
                                    property bool clicked: false
                                    anchors.fill: parent
                                    hoverEnabled: true

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

                                    onEntered: { // highlight item on hovering
                                        if (myCategoryTemplateList.currentIndex != 0) { // item is not selected
                                            myCategoryTemplate.opacity = 0.9
                                        }
                                    }

                                    onExited: { // reduce opacity on leaving
                                        if (myCategoryTemplateList.currentIndex != 0) { // item is not selected
                                            myCategoryTemplate.opacity = 0.4
                                        }
                                    }
                                }

                                Rectangle {
                                    width: rulersSize
                                    height: rulersSize
                                    radius: rulersSize
                                    color: Qt.rgba(theme.highlightColor.r,theme.highlightColor.g,theme.highlightColor.b, 1)
                                    anchors.horizontalCenter: parent.right
                                    anchors.verticalCenter: parent.verticalCenter

                                    MouseArea {
                                        anchors.fill: parent
                                        drag{ target: parent; axis: Drag.XAxis }
                                        onMouseXChanged: {
                                            if(drag.active){
                                                myCategoryTemplate.width = myCategoryTemplate.width + mouseX
                                                myCategoryTemplateList.buttonWidth = myCategoryTemplate.width
                                                if(myCategoryTemplate.width < units.iconSizes.huge)
                                                    myCategoryTemplate.width = units.iconSizes.huge
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
                                    color: Qt.rgba(theme.highlightColor.r,theme.highlightColor.g,theme.highlightColor.b, 1)
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.verticalCenter: parent.bottom

                                    MouseArea {
                                        anchors.fill: parent
                                        drag{ target: parent; axis: Drag.YAxis }
                                        onMouseYChanged: {
                                            if(drag.active){
                                                if(myCategoryTemplate.height + mouseY < units.iconSizes.smallMedium)
                                                    myCategoryTemplate.height = units.iconSizes.smallMedium
                                                else
                                                    myCategoryTemplate.height = myCategoryTemplate.height + mouseY
                                                myCategoryTemplateList.buttonHeight = myCategoryTemplate.height
                                            }
                                        }
                                    }
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
                }

                RowLayout {
                    Layout.fillWidth: true
                    visible: showCategories.checked
                    CheckBox {
                        Layout.leftMargin: units.smallSpacing
                        id: showCategoriesTooltip
                        text: i18n("Show categories' names in a tooltip when the text is elided or when using icons-only menu")
                    }
                }

                PlasmaExtras.Heading {
                    text: "Extra categories"
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
