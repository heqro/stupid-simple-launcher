import QtQuick 2.0

import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

// SwipeView and Spinbox values
import QtQuick.Controls 2.2

Item {

    id: configBackground

    property alias cfg_isBackgroundImageSet: setBackgroundImageCheckbox.checked
    property alias cfg_backgroundImage: fileDialog.chosenPath

    // Background properties
    property alias cfg_showLabelBackground: showBackgroundLabelCheckbox.checked
    property alias cfg_labelTransparency: labelAlphaValue.value

    property alias cfg_showCategoriesBackground: showBackgroundCategoriesCheckbox.checked
    property alias cfg_categoriesTransparency: categoriesListAlphaValue.value

    property alias cfg_showItemGridBackground: itemGridCheckbox.checked
    property alias cfg_itemGridTransparency: appsGridAlphaValue.value

    property alias cfg_showSessionControlBackground: sessionControlCheckbox.checked
    property alias cfg_sessionControlTransparency: sessionControlAlphaValue.value

    // Blur properties
    property alias cfg_blurSamples: samplesSpinbox.value
    property alias cfg_blurRadius: radiusSpinbox.value

    property alias cfg_isBlurEnabled: menuBlurCheckbox.checked
    property alias cfg_isWallpaperBlurred: blurBackgroundRButton.checked


    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter

        PlasmaExtras.Heading {
            text: i18n("Background image")
        }

        RowLayout{

            Row{
                spacing: units.smallSpacing

                CheckBox {
                    id: setBackgroundImageCheckbox
                    checked: false
                    text: i18n("Image background:")
                }

                TextField {
                    text: fileDialog.chosenPath
                    readOnly: true
                    visible: fileDialog.chosenPath != ''
                }

                Button {
                    id: imageButton
                    implicitWidth: height
                    PlasmaCore.IconItem {
                        anchors.fill: parent
                        source: "document-open-folder"
                        PlasmaCore.ToolTipArea {
                            anchors.fill: parent
                            subText: "Select image"
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {fileDialog.open() }
                    }
                }

                FileDialog {
                    id: fileDialog

                    property string chosenPath

                    selectMultiple : false
                    title: "Pick a image file"
                    nameFilters: [ "Image files (*.jpg *.png *.jpeg)", "All files (*)" ]
                    onAccepted: {
                        chosenPath = fileDialog.fileUrls[0]
                    }
                }
            }
        }

        PlasmaExtras.Heading {
            text: i18n("Opacity")
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: units.smallSpacing
            CheckBox{
                id: showBackgroundLabelCheckbox
                text: i18n("Add background to your applications' labels")
            }
        }

        RowLayout {
            Layout.fillWidth: true

            PlasmaComponents.Slider {
                id: labelAlphaValue
                enabled: showBackgroundLabelCheckbox.checked
            }

            PlasmaComponents.Label {
                text: Math.floor(labelAlphaValue.value * 100) + "%"
                visible: showBackgroundLabelCheckbox.checked
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: units.smallSpacing
            visible: plasmoid.configuration.showCategories
            CheckBox{
                id: showBackgroundCategoriesCheckbox
                text: i18n("Add background to your categories sidebar")
            }
        }

        RowLayout {
            Layout.fillWidth: true
            visible: plasmoid.configuration.showCategories

            PlasmaComponents.Slider {
                id: categoriesListAlphaValue
                enabled: showBackgroundCategoriesCheckbox.checked
            }

            PlasmaComponents.Label {
                text: Math.floor(categoriesListAlphaValue.value * 100) + "%"
                visible: showBackgroundCategoriesCheckbox.checked
            }
        }

        CheckBox {
            id: itemGridCheckbox
            text: i18n("Add background to applications grid and favorites grid")
        }

        RowLayout {
            Layout.fillWidth: true

            PlasmaComponents.Slider {
                id: appsGridAlphaValue
                enabled: itemGridCheckbox.checked
            }

            PlasmaComponents.Label {
                text: Math.floor(appsGridAlphaValue.value * 100) + "%"
                visible: itemGridCheckbox.checked
            }
        }

        CheckBox {
            id: sessionControlCheckbox
            text: i18n("Add background to the session control bar")
            visible: plasmoid.configuration.showSessionControlBar
        }

        RowLayout {
            visible: plasmoid.configuration.showSessionControlBar
            Layout.fillWidth: true

            PlasmaComponents.Slider {
                id: sessionControlAlphaValue
                enabled: sessionControlCheckbox.checked
            }

            PlasmaComponents.Label {
                text: Math.floor(sessionControlAlphaValue.value * 100) + "%"
                visible: sessionControlCheckbox.checked
            }
        }

        Row {
            CheckBox { id: menuBlurCheckbox }
            PlasmaExtras.Heading {
                text: i18n("Blur")
            }
        }

        Row {
            visible: menuBlurCheckbox.checked
            PlasmaComponents.Label {
                text: i18n('Samples: ')
                PlasmaCore.ToolTipArea {
                    mainText: i18n('Blur quality')
                    subText: i18n('The higher the better, at the cost of performance')
                    anchors.centerIn: parent
                    anchors.fill: parent
                }
            }
            SpinBox {
                id: samplesSpinbox
            }
        }


        Row {
            visible: menuBlurCheckbox.checked
            PlasmaComponents.Label {
                text: i18n('Radius: ')
                PlasmaCore.ToolTipArea {
                    mainText: i18n('Influence of a pixel on its neighboring pixels')
                    subText: i18n('The higher, the bigger blur effect')
                    anchors.centerIn: parent
                    anchors.fill: parent
                }
            }

            SpinBox {
                id: radiusSpinbox
            }
        }

        GroupBox {
            visible: menuBlurCheckbox.checked
            Column {
                PlasmaComponents.Label {
                    text: i18n('Apply blur...')
                }
                RadioButton {
                    id: blurItemsRButton
                    text: i18n('to the menu\'s items')
                    checked: true
                }
                RadioButton {
                    id: blurBackgroundRButton
                    text: i18n('to the wallpaper image')
                }
            }
        }

    }
}
