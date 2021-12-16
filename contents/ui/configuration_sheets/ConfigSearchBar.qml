import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

Item {
    id: configSidebar

    property alias cfg_searchBarNoDesign: designNull.checked
    property alias cfg_searchBarUnderline: designUnderline.checked
    property alias cfg_searchBarFullyFledged: designFullyFledged.checked

    property alias cfg_configureOpacity: opacitySetter.checked
    property alias cfg_searchBarOpacity: alphaValue.value

    ColumnLayout {
        PlasmaExtras.Heading {
            text: i18n("Design")
        }

        GroupBox {
            Layout.fillWidth: true
            ExclusiveGroup { id: designChoice}

            ColumnLayout {
                RadioButton {
                    Layout.fillWidth: true
                    id: designNull
                    text: i18n("No design")
                    checked: true
                    exclusiveGroup: designChoice
                }

                RadioButton {
                    Layout.fillWidth: true
                    id: designUnderline
                    text: i18n("Underlining")
                    exclusiveGroup: designChoice
                }

                RadioButton {
                    Layout.fillWidth: true
                    id: designFullyFledged
                    text: i18n("Fully-fledged")
                    exclusiveGroup: designChoice
                }

            }
        }

        PlasmaExtras.Heading {
            Layout.fillWidth: true
            text: i18n("Configure the design")
            visible: designFullyFledged.checked
        }

        CheckBox {
            Layout.fillWidth: true
            id: opacitySetter
            text: i18n("Select the search bar's opacity")
            visible: designFullyFledged.checked
        }

        RowLayout {
            visible: designFullyFledged.checked
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
