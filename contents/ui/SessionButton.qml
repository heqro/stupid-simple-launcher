import QtQuick 2.4
import org.kde.plasma.core 2.0 as PlasmaCore
// for using the button itself
import org.kde.plasma.components 3.0 as PlasmaComponents

// https://doc.qt.io/qt-5/qtquickcontrols2-icons.html

PlasmaComponents.Button {
    property string iconUrl
    flat: true
    icon.name: iconUrl
    icon.height: PlasmaCore.Units.iconSizes.large
    icon.width: PlasmaCore.Units.iconSizes.large
}
