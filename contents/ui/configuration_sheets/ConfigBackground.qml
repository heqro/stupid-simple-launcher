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

    property alias cfg_showLabelBackground: showBackgroundLabelCheckbox.checked
    property alias cfg_labelTransparency: labelAlphaValue.value

    property alias cfg_showCategoriesBackground: showBackgroundCategoriesCheckbox.checked
    property alias cfg_categoriesTransparency: categoriesListAlphaValue.value

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
                id: labelAlphaValueText
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
                id: categoriesListAlphaValueText
                text: Math.floor(categoriesListAlphaValue.value * 100) + "%"
                visible: showBackgroundCategoriesCheckbox.checked
            }
        }

        PlasmaExtras.Heading {
            text: i18n("Blur")
        }

    }
}
