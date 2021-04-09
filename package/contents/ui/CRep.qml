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


Item{
	id: root
	RowLayout{
		anchors.fill: parent
		
		Loader{
			id: compLoader
			sourceComponent: NumberBox { }
			Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
		}
		
		
		Binding{
			target: compLoader.item
			property: "text"
			value: pagerModel.currentPage + 1
		}
		
		
		states: [
			State {
				name: "horizontalPanel"
				when: plasmoid.formFactor === PlasmaCore.Types.Horizontal
				
				PropertyChanges {
					target: compLoader
					Layout.topMargin: height * .8 >= item.implicitHeight + 4 ? height * 0.1 : 0
					Layout.bottomMargin: height * .8 >= item.implicitHeight + 4 ? height * 0.1 : 0
					Layout.leftMargin: 0
					Layout.rightMargin: 0
				}
			},
			
			State {
				name: "verticalPanel"
				when: plasmoid.formFactor === PlasmaCore.Types.Vertical
				
				PropertyChanges {
					target: compLoader
					Layout.topMargin: 0
					Layout.bottomMargin: 0
					Layout.leftMargin: width * .8 >= item.implicitWidth + 4 ? width * 0.1 : 0
					Layout.rightMargin: width * .8 >= item.implicitWidth + 4 ? width * 0.1 : 0
				}
			},
			
			State{
				name: "other"
				when: plasmoid.formFactor !== PlasmaCore.Types.Horizontal && plasmoid.formFactor !== PlasmaCore.Types.Vertical
				
				PropertyChanges {
					target: compLoader
					Layout.topMargin: 0
					Layout.bottomMargin: 0
					Layout.leftMargin: 0
					Layout.rightMargin: 0
					Layout.fillHeight: true
					Layout.fillWidth: true
					Layout.preferredHeight: root.height
					Layout.preferredWidth: root.width
				}
			}
		]
	}
	
	MouseArea{
		anchors.fill: parent
		
		onClicked: plasmoid.expanded = ! plasmoid.expanded
		onWheel: switchDesktop(wheel)
	}
}


