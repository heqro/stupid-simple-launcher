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

    ColumnLayout {
        PlasmaExtras.Heading {
            text: "Design"
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
            }
        }
    }

}
