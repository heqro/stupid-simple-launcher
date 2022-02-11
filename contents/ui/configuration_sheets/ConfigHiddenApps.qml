
/***************************************************************************
 *   Copyright (C) 2022 by Hector Iglesias <heqromancer@gmail.com>         *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

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
import org.kde.kirigami 2.5 as Kirigami

Item {
    id: configGeneral


    property var cfg_hiddenApplications:            plasmoid.configuration.hiddenApplications
    property var cfg_hiddenApplicationsName:        plasmoid.configuration.hiddenApplicationsName
    property var cfg_hiddenApplicationsDescription: plasmoid.configuration.hiddenApplicationsDescription
    property var cfg_hiddenApplicationsUrl:         plasmoid.configuration.hiddenApplicationsUrl
    property var cfg_hiddenApplicationsIcon:        plasmoid.configuration.hiddenApplicationsIcon

    ColumnLayout {

        anchors.fill: parent

        ColumnLayout {

            Layout.fillHeight: true
            Layout.fillWidth: true

            Kirigami.InlineMessage {
                type: Kirigami.MessageType.Positive
                visible: !moduleUnavailableMessage.visible && cfg_hiddenApplications.length == 0
                Layout.fillWidth: true
                text: i18n("Hide some applications at the dashboard to manage them from this module.")
            }

            Kirigami.InlineMessage { // This will only show for versions of this menu prior to this implementation.
                id: moduleUnavailableMessage
                type: Kirigami.MessageType.Error
                visible: plasmoid.configuration.hiddenApplications.length != plasmoid.configuration.hiddenApplicationsName.length
                Layout.fillWidth: true
                text: i18n("Module not available. Please delete the hidden applications list to manage the apps you hide from now on.")
                actions: [
                    Kirigami.Action {
                        icon.name: "edit-clear-history"
                        text: i18n("Clear hidden apps list")
                        onTriggered: { // Clear everything to start anew

//                             var emptyApps = []
//                             var emptyName = []
//                             var emptyDesc = []
//                             var emptyUrl  = []
//                             var emptyIcon = []

//                             plasmoid.configuration.hiddenApplications = emptyApps
//                             plasmoid.configuration.hiddenApplicationsName = emptyName
//                             plasmoid.configuration.hiddenApplicationsDescription = emptyDesc
//                             plasmoid.configuration.hiddenApplicationsUrl = emptyUrl
//                             plasmoid.configuration.hiddenApplicationsIcon = emptyIcon

//                             cfg_hiddenApplications              = emptyApps
//                             cfg_hiddenApplicationsName          = emptyName
//                             cfg_hiddenApplicationsDescription   = emptyDesc
//                             cfg_hiddenApplicationsUrl           = emptyUrl
//                             cfg_hiddenApplicationsIcon          = emptyIcon
                            cfg_hiddenApplications              = []
                            cfg_hiddenApplicationsName          = []
                            cfg_hiddenApplicationsDescription   = []
                            cfg_hiddenApplicationsUrl           = []
                            cfg_hiddenApplicationsIcon          = []
                            hiddenAppsView.loadHiddenApps()
                        }
                    }
                ]
            }

            ListView {
                id: hiddenAppsView

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: units.iconSizes.small
                spacing: units.iconSizes.small

                model: ListModel {
                    id: hiddenApplicationsModel
                }

                delegate: Rectangle {

                    id: hiddenAppsRectangle

                    property string name: hiddenAppsName
                    property string description: hiddenAppsDescription
                    property string icon: hiddenAppsIcon
                    property int indexInList: hiddenAppsIndex

                    color: theme.buttonBackgroundColor
    //                 border.color: isSearchBarFocused ? colorWithAlpha(theme.buttonFocusColor, 1) : colorWithAlpha(theme.highlightColor, 1)
                    border.color: theme.buttonFocusColor
                    height: units.iconSizes.huge + 2 * units.iconSizes.small
                    width: parent.width

                    RowLayout {

                        id: hiddenAppsRow
                        anchors.fill: parent

                        PlasmaCore.IconItem {
                            id: hiddenAppIconId
                            source: icon
                            Layout.preferredWidth: units.iconSizes.huge
                            Layout.preferredHeight: units.iconSizes.huge
                            Layout.leftMargin: units.iconSizes.small
                            //Layout.fillHeight: true
                            //Layout.fillWidth: true
                            //Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                        }

                        ColumnLayout {

                            id: columnWithText
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Layout.leftMargin: units.iconSizes.small
                            Layout.rightMargin: units.iconSizes.small

                            Kirigami.Heading {
                                level: 1
                                text: name
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.topMargin: units.iconSizes.small
                                Layout.bottomMargin: units.iconSizes.small
                            }

                            Kirigami.Separator {
                                Layout.fillWidth: true
                            }

                            PlasmaComponents.Label {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                Layout.topMargin: units.iconSizes.small
                                Layout.bottomMargin: units.iconSizes.small
                                wrapMode: Text.WordWrap
                                elide: Text.ElideRight
                                text: /*"Placeholder"*/description
                            }
                        }

                        PlasmaComponents.Button {
                            id: confirmAccept
                            Layout.rightMargin: units.iconSizes.small
                            visible: false
                            text: qsTr("Confirm")
                            iconSource: "dialog-apply"
                            onClicked: {

                                var indexInAppsArray = plasmoid.configuration.hiddenApplications.length - indexInList - 1

                                var newHiddenApps = cfg_hiddenApplications
                                newHiddenApps.splice(indexInAppsArray, 1)
    //                             console.log("hiddenApplications actual: ", newHiddenApps)
                                cfg_hiddenApplications = newHiddenApps

                                var newHiddenAppsName = cfg_hiddenApplicationsName
                                newHiddenAppsName.splice(indexInAppsArray, 1)

                                var newHiddenAppsDescription    = cfg_hiddenApplicationsDescription
                                newHiddenAppsDescription.splice(indexInAppsArray, 1)

                                var newHiddenAppsUrl            = cfg_hiddenApplicationsUrl
                                newHiddenAppsUrl.splice(indexInAppsArray, 1)

                                var newHiddenAppsIcon           = cfg_hiddenApplicationsIcon
                                newHiddenAppsIcon.splice(indexInAppsArray, 1)

//                                 plasmoid.configuration.hiddenApplicationsName           = newHiddenAppsName
//                                 plasmoid.configuration.hiddenApplicationsDescription    = newHiddenAppsDescription
//                                 plasmoid.configuration.hiddenApplicationsUrl            = newHiddenAppsUrl
//                                 plasmoid.configuration.hiddenApplicationsIcon           = newHiddenAppsIcon

                                cfg_hiddenApplicationsName          = newHiddenAppsName
                                cfg_hiddenApplicationsDescription   = newHiddenAppsDescription
                                cfg_hiddenApplicationsUrl           = newHiddenAppsUrl
                                cfg_hiddenApplicationsIcon          = newHiddenAppsIcon

                                hiddenAppsView.loadHiddenApps()

                            }
                        }

                        PlasmaComponents.Button {
                            id: confirmCancel
                            Layout.rightMargin: units.iconSizes.small
                            text: qsTr("Cancel")
                            visible: false
                            iconSource: "dialog-cancel"
                            onClicked: {
                                confirmAccept.visible = false
                                confirmCancel.visible = false
                                restoreApp.visible = true
                            }
                        }

                        PlasmaComponents.Button {
                            id: restoreApp
                            Layout.rightMargin: units.iconSizes.small

                            text: qsTr("Restore")
                            onClicked: {
                                confirmAccept.visible = true
                                confirmCancel.visible = true
                                restoreApp.visible = false
                            }
                        }

                    }


                }

                function loadHiddenApps() {
                    //if (moduleUnavailableMessage.visible) return;
                    hiddenApplicationsModel.clear()
                    for (var i = 0; i < cfg_hiddenApplicationsName.length; i++) {
                        //                     console.log("Iteración", i)
                        var name = cfg_hiddenApplicationsName[i]
                        var description = cfg_hiddenApplicationsDescription[i]
                        var icon = cfg_hiddenApplicationsIcon[i] == "undefined" ? "unknown" : cfg_hiddenApplicationsIcon[i]
                        var index = cfg_hiddenApplicationsName.length - i - 1

                        hiddenApplicationsModel.insert(0, {"hiddenAppsName": name, "hiddenAppsDescription": description, "hiddenAppsIcon": icon, "hiddenAppsIndex": index}) // insert items on the list based on recency - latest hidden is shown first.

                    }

    //                 console.log("PLASMOID HIDDEN APPS", plasmoid.configuration.hiddenApplications)
    //                 console.log("PLASMOID HIDDEN ICONS", plasmoid.configuration.hiddenApplicationsIcon)

                }
            }


        }

        PlasmaComponents.Button {
            //Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            //             Layout.fillHeight: true
            visible: cfg_hiddenApplications.length != 0
            text: i18n("Clear hidden apps list")
            iconSource: "edit-clear-history"

            onClicked: {

//                 var emptyApps = []
//                 var emptyName = []
//                 var emptyDesc = []
//                 var emptyUrl  = []
//                 var emptyIcon = []

//                 plasmoid.configuration.hiddenApplications = emptyApps
//                 plasmoid.configuration.hiddenApplicationsName = emptyName
//                 plasmoid.configuration.hiddenApplicationsDescription = emptyDesc
//                 plasmoid.configuration.hiddenApplicationsUrl = emptyUrl
//                 plasmoid.configuration.hiddenApplicationsIcon = emptyIcon
                cfg_hiddenApplications              = []
                cfg_hiddenApplicationsName          = []
                cfg_hiddenApplicationsDescription   = []
                cfg_hiddenApplicationsUrl           = []
                cfg_hiddenApplicationsIcon          = []
                hiddenApplicationsModel.clear()

                //                 console.log("Extensión: ",plasmoid.configuration.hiddenApplications.length)
                //                 console.log("Extensión: ",plasmoid.configuration.hiddenApplicationsName.length)
            }
        }
    }

    Component.onCompleted: {
        hiddenAppsView.loadHiddenApps()
    }
}
