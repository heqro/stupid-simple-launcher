/***************************************************************************
 *   Copyright (C) 2014 by Eike Hein <hein@kde.org>                        *
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

import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

// SwipeView and Spinbox values
import QtQuick.Controls 2.2

Item {
    id: configGeneral

    property string cfg_icon: plasmoid.configuration.icon

    property alias cfg_iconSize:      iconSize.value
    property alias cfg_favoritesIconSize: favoritesIconSize.value

    property alias cfg_tooltipsInGrid: tooltipsInGrid.checked

    property alias cfg_favoritesInGrid: favoritesInGrid.checked
    property alias cfg_writeSomething: writeSomething.checked
    property alias cfg_greetingText: greetingText.text

    property alias cfg_opacitySet: opacitySetter.checked
    property alias cfg_alphaValue: alphaValue.value

    property alias cfg_clickToToggle: clickToToggle.checked

    property alias cfg_startOnFavorites: startOnFavorites.checked

    property alias cfg_paginateGrid: paginateGrid.checked

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter

        PlasmaExtras.Heading {
            text: "Icons"
        }

        RowLayout {
            spacing: units.smallSpacing

            Label {
                text: i18n("Icon:")
            }

            IconPicker {
                currentIcon: cfg_icon
                defaultIcon: "start-here-kde"
                onIconChanged: cfg_icon = iconName
            }
        }

        RowLayout{
            Layout.fillWidth: true
            Label {
                Layout.leftMargin: units.smallSpacing
                text: i18n("Size of icons")
            }
            SpinBox{
                id: iconSize
                from: 24
                to: 256
                stepSize: 4
            }
        }

        PlasmaExtras.Heading {
            text: "Layout"
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: units.smallSpacing
            CheckBox{
                id: tooltipsInGrid
                text: i18n("Show tooltips when hovering on an application")
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: units.smallSpacing
            CheckBox{
                id: favoritesInGrid
                text: i18n("Show favorite applications")
            }
        }

        RowLayout{
            Layout.fillWidth: true
            Label {
                Layout.leftMargin: units.smallSpacing
                text: i18n("Size of favorite icons")
            }
            SpinBox{
                id: favoritesIconSize
                from: 24
                to: 256
                stepSize: 4
            }
        }

        RowLayout {
            Layout.fillWidth: true
            CheckBox {
                Layout.leftMargin: units.smallSpacing
                id: writeSomething
                text: i18n("Write a greeting text")
            }
            PlasmaComponents.TextField {
                id: greetingText
                enabled: writeSomething.checked
            }
        }

        CheckBox {
            Layout.fillWidth: true
            Layout.leftMargin: units.smallSpacing
            id: paginateGrid
            text: i18n("Paginate the applications grid")
        }

        RowLayout {
            Layout.fillWidth: true

            CheckBox {
                Layout.leftMargin: units.smallSpacing
                id: opacitySetter
                text: i18n("Select the menu's opacity")
            }
        }

        RowLayout {
            Layout.fillWidth: true

            PlasmaComponents.Slider {
                id: alphaValue
                enabled: opacitySetter.checked
            }

            PlasmaComponents.Label {
                id: alphaValueText
                text: Math.floor(alphaValue.value * 100) + "%"
                visible: opacitySetter.checked
            }
        }

        PlasmaExtras.Heading {
            text: i18n("Behavior")
        }

        RowLayout {

            Layout.fillWidth: true

            CheckBox {
                Layout.leftMargin: units.smallSpacing
                id: clickToToggle
                text: i18n("Hide the menu by clicking in an empty region")
            }
        }

        PlasmaExtras.Heading {
            text: "Startup"
        }

        RowLayout {
            Layout.fillWidth: true

            CheckBox {
                Layout.leftMargin: units.smallSpacing
                id: startOnFavorites
                text: i18n("Start the menu on the \"Favorites\" category")
            }
        }

    }

}
