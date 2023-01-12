import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import ".."

Item {
    id: configSidebar

    property alias cfg_configureOpacity: opacitySetter.checked
    property alias cfg_searchBarOpacity: alphaValue.value

    property alias cfg_searchBarDesign: designChooser.chosenDesignSheetPath

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        PlasmaExtras.Heading {
            text: i18n("Choose a design")
        }

        GroupBox {
            id: designChooser
            ExclusiveGroup { id: designChoice }

            property string chosenDesignSheetPath: plasmoid.configuration.searchBarDesign

            ColumnLayout {
                RadioButton {
                    //Layout.fillWidth: true
                    id: designNull
                    text: i18n("No design")
                    checked: plasmoid.configuration.searchBarDesign == ""
                    exclusiveGroup: designChoice

                    onCheckedChanged: {
                        if (checked)
                            designChooser.chosenDesignSheetPath = ""
                    }
                }

                RadioButton {
                    //Layout.fillWidth: true
                    id: designUnderline
                    text: i18n("Underlining")
                    exclusiveGroup: designChoice
                    checked: plasmoid.configuration.searchBarDesign == "searchbar_designs/Underlining.qml"

                    onCheckedChanged: {
                        if (checked)
                            designChooser.chosenDesignSheetPath = "searchbar_designs/Underlining.qml"
                    }
                }

                RadioButton {
                    //Layout.fillWidth: true
                    id: designFullyFledged
                    text: i18n("Fully-fledged")
                    exclusiveGroup: designChoice
                    checked: plasmoid.configuration.searchBarDesign == "searchbar_designs/FullyFledged.qml"
                    onCheckedChanged: {
                        if (checked)
                            designChooser.chosenDesignSheetPath = "searchbar_designs/FullyFledged.qml"
                    }
                }

                RadioButton {
                    //Layout.fillWidth: true
                    id: designMaterial
                    text: i18n("Material")
                    exclusiveGroup: designChoice
                    checked: plasmoid.configuration.searchBarDesign == "searchbar_designs/MaterialOutlined.qml"
                    onCheckedChanged: {
                        if (checked)
                            designChooser.chosenDesignSheetPath = "searchbar_designs/MaterialOutlined.qml"
                    }
                }

                RadioButton {
                    //Layout.fillWidth: true
                    id: designModernComfy
                    text: i18n("Modern comfy")
                    exclusiveGroup: designChoice
                    checked: plasmoid.configuration.searchBarDesign == "searchbar_designs/ModernComfy.qml"
                    onCheckedChanged: {
                        if (checked)
                            designChooser.chosenDesignSheetPath = "searchbar_designs/ModernComfy.qml"
                    }
                }

            }
        }


        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: units.largeSpacing
            Layout.bottomMargin: units.mediumSpacing
            PlasmaExtras.Heading {
                Layout.alignment: Qt.AlignLeft
                text: i18n("Testing ground")
            }
        }


        SearchBar {

            id: testSearchBar
//             Layout.fillWidth:true
            writeSomething:  true
            greetingText:    "Sample greeting text"
            searchBarDesign: designChooser.chosenDesignSheetPath
            searchBarOpacity:alphaValue.value
        }

        PlasmaComponents.Button {
            text: i18n("Restore search bar")
            iconSource: "edit-clear-all"
            enabled: testSearchBar.focus

            Layout.topMargin: units.mediumSpacing

            onClicked: testSearchBar.unfocus()
        }

        PlasmaExtras.Heading {
            Layout.fillWidth: true
            Layout.topMargin: units.largeSpacing
            text: i18n("Configure the design")
            visible: designFullyFledged.checked
        }


        CheckBox {
            Layout.fillWidth: true
            id: opacitySetter
            text: i18n("Select the search bar's opacity")
            visible: !designNull.checked
        }

        RowLayout {
            visible: !designNull.checked
            Layout.fillWidth: true

            PlasmaComponents.Slider {
                id: alphaValue
                visible: opacitySetter.checked
                enabled: opacitySetter.checked
            }

            PlasmaComponents.Label {
                id: alphaValueText
                text: Math.floor(alphaValue.value * 100) + "%"
                visible: opacitySetter.checked
            }
        }
    }
}
