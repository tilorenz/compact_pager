/*
 * Copyright 2021  Tino Lorenz <tilrnz@gmx.net>
 * Copyright 2022  Diego Miguel <hello@diegomiguel.me>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import QtQuick 2.6
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddonsComponents
import org.kde.plasma.private.pager 2.0

Rectangle {
	property alias text: numberText.text 
	property bool fontSizeChecked: plasmoid.configuration.fontSizeChecked
	property color fontColor: plasmoid.configuration.fontColorChecked ? 
			plasmoid.configuration.fontColor : PlasmaCore.Theme.textColor

	border.width: plasmoid.configuration.displayBorder ? plasmoid.configuration.borderThickness : 0
	radius: height > width ? height * (plasmoid.configuration.borderRadius / 100) : width * (plasmoid.configuration.borderRadius / 100)

	Text {
		id: numberText

		anchors.centerIn: parent
		text: pagerModel.currentPage + 1
		color: fontColor
	 	font {
			family: plasmoid.configuration.fontFamily || PlasmaCore.Theme.defaultFont.family
			bold: plasmoid.configuration.fontBold
			italic: plasmoid.configuration.fontItalic
			pixelSize: fontSizeChecked ? plasmoid.configuration.fontSize : Math.min(parent.height*0.7, parent.width*0.7)
		}
	}
}
