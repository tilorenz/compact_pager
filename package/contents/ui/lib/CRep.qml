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

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kquickcontrolsaddons as KQuickControlsAddonsComponents
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.pager


Item {
	id: compactLayout

	property color fontColor: plasmoid.configuration.fontColorChecked ? 
			plasmoid.configuration.fontColor : Kirigami.Theme.textColor

	Loader {
		id: compLoader
		width: parent.width * 0.75
		height: parent.height * 0.85
		anchors.centerIn: parent

		sourceComponent: NumberBox {
			color: plasmoid.configuration.activeBgColorChecked ?
					plasmoid.configuration.activeBgColor : Kirigami.Theme.backgroundColor
			border.color: plasmoid.configuration.sameBorderColorAsFont ? 
					fontColor : plasmoid.configuration.borderColor
		}
	}

	Binding {
		target: compLoader.item
		property: "text"
		value: pagerModel.currentPage + 1
	}
	MouseArea {
		anchors.fill: parent
		onClicked: {
			if (plasmoid.configuration.overviewCompactLayout) {
				runOverview()
			} else {
				root.expanded = !root.expanded
			}
		}
		onWheel: (wheel) => { plasmoid.configuration.enableScrolling ? switchDesktop(wheel) : {} }
	}
}
