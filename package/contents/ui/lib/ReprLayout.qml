/*
 * Copyright 2021-2024  Tino Lorenz <tilrnz@gmx.net>
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
	id: reprLayout
	property bool isFullRep: true

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
	property color bgColorWithoutWindows: plasmoid.configuration.inactiveBgColorWithoutWindowsChecked ?
		plasmoid.configuration.inactiveBgColorWithoutWindows : bgColor
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

	property bool shouldShowFullLayout: {
		if (isFullRep) {
			return true
		}
		switch (plasmoid.configuration.forceLayout) {
			case 0: return properLayoutFits(modelColumns()) // adaptive
			case 1: return true // full
			case 2: return false // compact
		}
	}


	columns: {
		let cols = modelColumns()

		// names are larger and don't all have equal width, so there's no point even
		// trying to figure out if it would fit
		if (plasmoid.configuration.showDesktopNames) {
			return cols
		}

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
			visible: reprLayout.shouldShowFullLayout || index === pagerModel.currentPage
			// TODO fix in plasma
			text: (plasmoid.configuration.showDesktopNames && model.display != "") ? model.display : index + 1
			Layout.fillWidth: true
			Layout.fillHeight: true
			Layout.minimumWidth: implicitWidth
			Layout.preferredHeight: implicitHeight
			Layout.minimumHeight: 20
			Layout.preferredWidth: Math.max(implicitWidth, height)
			Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

			// this is horrible, is there really no other way to do this in qml???
			Repeater {
				id: proxyRepeater
				model: TasksModel
				Rectangle { visible: false }
			}
			showWindowIndicator: plasmoid.configuration.showWindowIndicator && proxyRepeater.count > 0

			//highlight the current desktop
			color: index === pagerModel.currentPage ? bgColorHighlight :
				((proxyRepeater.count > 0) ? bgColor : bgColorWithoutWindows)
			border.color: index === pagerModel.currentPage ? borderColorHighlight : borderColor

			MouseArea {
				anchors.fill: parent
				onClicked: {
					// when clicking on the desktop we're already on
					if (model.index === pagerModel.currentPage) {
						// ...and we're in full layout or configured to do an action in compact layout...
						if (reprLayout.shouldShowFullLayout || plasmoid.configuration.actionOnCompactLayout) {
							// do some action
							switch (plasmoid.configuration.currentDesktopSelected) {
								case 0: // do nothing
									break;
								case 1: // show desktop
									pagerModel.changePage(pagerModel.currentPage)
									break;
								case 2:
									runOverview()
									break;
							}
							root.expanded = false
						} else {
							root.expanded = !root.expanded
						}
					} else {
						pagerModel.changePage(model.index)
						root.expanded = false
					}
				}
			}
		}
	}
}
