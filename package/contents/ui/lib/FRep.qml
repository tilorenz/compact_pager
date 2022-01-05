/*
 * Copyright 2021  Tino Lorenz <tilrnz@gmx.net>
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

GridLayout{
	property color bgColorHighlight: plasmoid.configuration.bgColorChecked ?
										Qt.rgba(plasmoid.configuration.bgColor.r,
												plasmoid.configuration.bgColor.g,
												plasmoid.configuration.bgColor.b,
												plasmoid.configuration.bgOpacity / 100
										) : "transparent"
	// Dim borders of all but current desktop
	property color bgColor: Qt.rgba(
		Math.max(0, bgColorHighlight.r - 0.4),
		Math.max(0, bgColorHighlight.g - 0.4),
		Math.max(0, bgColorHighlight.b - 0.4),
		bgColorHighlight.a
	)
	property color borderColorHighlight: plasmoid.configuration.borderColor 
	// Dim borders of all but current desktop
	property color borderColor: Qt.rgba(
		Math.max(0, borderColorHighlight.r - 0.6),
		Math.max(0, borderColorHighlight.g - 0.6),
		Math.max(0, borderColorHighlight.b - 0.6),
		borderColorHighlight.a
	)
	//anchors.fill: parent
	columns: Math.ceil(pagerModel.count / pagerModel.layoutRows)
	
	Repeater{
		id: dRep
		model: pagerModel
		NumberBox{
			id: nBox
			text: index + 1
			
			Layout.fillWidth: true
			Layout.fillHeight: true
			Layout.minimumHeight: 40
			Layout.minimumWidth: 40
			
			//highlight the current desktop
			color: index === pagerModel.currentPage ? bgColorHighlight : bgColor
			border.color: index === pagerModel.currentPage ? borderColorHighlight : borderColor
			
			MouseArea{
				anchors.fill: parent
				onClicked: {
					pagerModel.changePage(model.index)
					//TODO maybe add option for this
					plasmoid.expanded = false
				}
			}
		}
	}

	MouseArea{
		Layout.fillWidth: true
		Layout.fillHeight: true
		onWheel: switchDesktop(wheel)
		// Let clicks through to the MouseAreas in the NumberBoxes
		propagateComposedEvents: true
	}
}
