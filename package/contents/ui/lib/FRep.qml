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


GridLayout {
	id: fullLayout

	property color bgColorHighlight: plasmoid.configuration.activeBgColorChecked ?
			plasmoid.configuration.activeBgColor : Kirigami.Theme.backgroundColor

	property color fontColor: plasmoid.configuration.fontColorChecked ? 
			plasmoid.configuration.fontColor : Kirigami.Theme.textColor

	// Dim backgrounds of all but current desktop
	property color bgColor: plasmoid.configuration.inactiveBgColorChecked ?
		plasmoid.configuration.inactiveBgColor :
		Qt.rgba(
			Math.max(0, bgColorHighlight.r * 0.65),
			Math.max(0, bgColorHighlight.g * 0.65),
			Math.max(0, bgColorHighlight.b * 0.65),
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

	function modelColumns() {
		return Math.ceil(pagerModel.count / pagerModel.layoutRows)
	}

	// if we have the space to lay the desktops out like the model says
	function properLayoutFits(cols) {
		let wantedWidth = 20 * cols
		let wantedHeight = 20 * pagerModel.layoutRows
		return width >= wantedWidth && height >= wantedHeight
	}

	columns: {
		let cols = modelColumns()

		switch (Plasmoid.formFactor) {
			// for vertical and horizontal panels, we ignore the height and width, respectively
			// since the plasmoid can scale in those directions
			case 2: { // horizontal
				let availableRows = Math.floor(height / 20)
				let targetRows = Math.max(Math.min(availableRows, pagerModel.layoutRows), 1)
				return Math.ceil(pagerModel.count / targetRows)
			}
			case 3: { // vertical
				let availableColumns = Math.floor(width / 20)
				return Math.max(Math.min(availableColumns, cols), 1)
			}
			default:
				return cols
		}
	}

	Repeater {
		id: dRep
		model: pagerModel

		NumberBox {
			id: nBox
			text: index + 1
			Layout.fillWidth: true
			Layout.fillHeight: true
			//Layout.preferredWidth: 40
			//Layout.preferredHeight: Layout.preferredWidth
			Layout.minimumWidth: 18
			Layout.minimumHeight: 18
			Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

			//highlight the current desktop
			color: index === pagerModel.currentPage ? bgColorHighlight : bgColor
			border.color: index === pagerModel.currentPage ? borderColorHighlight : borderColor

			MouseArea {
				anchors.fill: parent
				onClicked: {
					if (plasmoid.configuration.currentDesktopSelected === 2 && model.index === pagerModel.currentPage) {
						runOverview()
					} else {
						pagerModel.changePage(model.index)
					}
					//TODO maybe add option for this
					root.expanded = false
				}
			}
		}
	}
}
