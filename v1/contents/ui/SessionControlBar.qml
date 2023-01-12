
// for using RowLayout
import QtQuick.Layouts 1.1

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.plasma.extras 2.0 as PlasmaExtras

RowLayout {

    property bool showButtonTooltips
    spacing: units.iconSizes.medium // arbitrary spacing between buttons whose value is non-arbitrary (it's taken from KDE Plasma's API so I trust they will work on other displays)

    // The following SessionButtons are defined in SessionButton.qml. They are basically Buttons taken from the PlasmaComponents library with some values that will always be present - thus, I just put them in a separate qml file to avoid repeating lines of code.
    SessionButton { // Shutdown Button
        actionName: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Shut Down")
        iconUrl: "system-shutdown"
        commandToLaunch: 'qdbus org.kde.ksmserver /KSMServer logout -1 2 2'
        showButtonTooltip: showButtonTooltips
    }

    SessionButton { // Restart Button
        actionName: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Restart")
        iconUrl: "system-reboot"
        commandToLaunch: 'qdbus org.kde.ksmserver /KSMServer logout -1 1 2'
        showButtonTooltip: showButtonTooltips
    }

    SessionButton { // Logout Button
        actionName: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Log Out")
        iconUrl: "system-log-out"
        commandToLaunch: 'qdbus org.kde.ksmserver /KSMServer logout -1 0 2'
        showButtonTooltip: showButtonTooltips
    }

    SessionButton { // Lock Screen Button
        actionName: i18n("Lock Screen")
        iconUrl: "system-lock-screen"
        commandToLaunch: 'qdbus org.freedesktop.ScreenSaver /ScreenSaver Lock'
        showButtonTooltip: showButtonTooltips
    }

    PlasmaCore.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: disconnectSource(sourceName)

        function exec(cmd) {
            executable.connectSource(cmd)
        }
    }
}
