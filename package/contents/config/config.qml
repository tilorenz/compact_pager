/*
 *  Copyright 2013  Marco Martin <mart@kde.org>
 *  Copyright 2022  Diego Miguel <hello@diegomiguel.me>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick

import org.kde.plasma.configuration

ConfigModel {
	ConfigCategory {
		name: i18n("General")
		icon: "preferences-desktop-plasma"
 		source: "config/configGeneral.qml"
	}
	ConfigCategory {
		name: i18n("Appearance")
 		icon: "preferences-desktop-color"
		source: "config/configAppearance.qml"
	}
}
