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

import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
         name: i18n("General")
         icon: "kde"
         source: "configuration_sheets/ConfigGeneral.qml"
    }

    ConfigCategory {
        name: i18n("Categories sidebar")
        icon: "view-list-icons"
        source: "configuration_sheets/ConfigCategory.qml"
    }

    ConfigCategory {
        name: i18n("Searchbar")
        icon: "search"
        source: "configuration_sheets/ConfigSearchBar.qml"
    }

    ConfigCategory {
        name: i18n("Session control bar")
        icon: "preferences-system-login"
        source: "configuration_sheets/ConfigSessionControl.qml"
    }

    ConfigCategory {
        name: i18n("Background, opacity, blur")
        icon: "preferences-desktop-wallpaper"
        source: "configuration_sheets/ConfigBackground.qml"
    }

    ConfigCategory {
        name: i18n("Hidden apps management")
        icon: "applications-all"
        source: "configuration_sheets/ConfigHiddenApps.qml"
    }
}
