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
	anchors.fill: parent
	columns: Math.ceil(pagerModel.count / pagerModel.layoutRows)
	
	Repeater{
		id: dRep
		model: pagerModel
		NumberBox{
			id: nBox
			text: index + 1
			
			Layout.fillHeight: true
			Layout.fillWidth: true
			//make the popup a little larger
			Layout.preferredHeight: implicitHeight * 3
			Layout.preferredWidth: implicitWidth * 3
			
			//highlight the current desktop
			border.color: index === pagerModel.currentPage ? PlasmaCore.Theme.highlightColor : PlasmaCore.Theme.textColor
			
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
		width: parent.width
		height: parent.height
		onWheel: switchDesktop(wheel)
		//let clicks through to the MouseAreas in the NumberBoxes
		propagateComposedEvents: true
	}
}
