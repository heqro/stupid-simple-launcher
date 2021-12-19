import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

Item {
    id: configSessionControl

    property alias cfg_showSessionControlTooltips: showTooltips.checked

    ColumnLayout {
        PlasmaExtras.Heading {
            text: i18n("Behavior")
        }
        CheckBox {
            Layout.fillWidth: true
            id: showTooltips
            text: i18n("Show tooltips on each session control button")
        }
    }
}
