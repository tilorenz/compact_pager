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
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddonsComponents
import org.kde.plasma.private.pager 2.0


GridLayout {
	id: fullLayout

	property color bgColorHighlight: plasmoid.configuration.bgColorChecked ?
			plasmoid.configuration.bgColor : PlasmaCore.Theme.backgroundColor

	property color fontColor: plasmoid.configuration.fontColorChecked ? 
			plasmoid.configuration.fontColor : PlasmaCore.Theme.textColor

	// Dim backgrounds of all but current desktop
	property color bgColor: Qt.rgba(
		Math.max(0, bgColorHighlight.r - 0.4),
		Math.max(0, bgColorHighlight.g - 0.4),
		Math.max(0, bgColorHighlight.b - 0.4),
		bgColorHighlight.a
	)
	property color borderColorHighlight: plasmoid.configuration.sameBorderColorAsFont ? 
			fontColor : plasmoid.configuration.borderColor

	// Dim borders of all but current desktop
	property color borderColor: Qt.rgba(
		Math.max(0, borderColorHighlight.r - 0.4),
		Math.max(0, borderColorHighlight.g - 0.4),
		Math.max(0, borderColorHighlight.b - 0.4),
		borderColorHighlight.a
	)

	columns: {
		let isVertical = height > width;
		// If there's not enough vertical space, show in one row
		if (!isVertical && height < 40) {
			return pagerModel.count
		// If there's not enough horizontal space, show in one column
		} else if (isVertical && width < 60) {
			return 1
		}
		return Math.ceil(pagerModel.count / pagerModel.layoutRows)
	}

	Repeater {
		id: dRep
		model: pagerModel

		NumberBox {
			id: nBox
			text: index + 1
			Layout.fillWidth: true
			Layout.fillHeight: true
			Layout.preferredWidth: 40
			Layout.preferredHeight: Layout.preferredWidth
			Layout.minimumWidth: 18
			Layout.minimumHeight: Layout.minimumWidth
			Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

			//highlight the current desktop
			color: index === pagerModel.currentPage ? bgColorHighlight : bgColor
			border.color: index === pagerModel.currentPage ? borderColorHighlight : borderColor

			MouseArea {
				anchors.fill: parent
				onClicked: {
					pagerModel.changePage(model.index)
					//TODO maybe add option for this
					plasmoid.expanded = false
				}
				onWheel: switchDesktop(wheel)
			}
		}
	}
}
