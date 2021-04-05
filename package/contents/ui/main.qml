/*
 * Copyright 2012  Luís Gabriel Lima <lampih@gmail.com>
 * Copyright 2016  Kai Uwe Broulik <kde@privat.broulik.de>
 * Copyright 2016  Eike Hein <hein@kde.org>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.15
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddonsComponents
import org.kde.plasma.private.pager 2.0

Item{
	id: root
	Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation
	Plasmoid.status:  PlasmaCore.Types.ActiveStatus //pagerModel.shouldShowPager ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.HiddenStatus
	
	property int wheelDelta: 0
	
	function colorWithAlpha(color, alpha) {
		return Qt.rgba(color.r, color.g, color.b, alpha)
	}
	
	function action_addDesktop() {
		pagerModel.addDesktop();
	}
	
	function action_removeDesktop() {
		pagerModel.removeDesktop();
	}
	
	function action_openKCM() {
		KQuickControlsAddonsComponents.KCMShell.openSystemSettings("kcm_kwin_virtualdesktops");
	}
	
	function switchDesktop(wheel){
		//		console.log("angleDelta y: ", wheel.angleDelta.y, " x: ", wheel.angleDelta.x)
		//		console.log("current page: ", pagerModel.currentPage, " count: ", pagerModel.count)
		
		// Magic number 120 for common "one click, see:
		// https://doc.qt.io/qt-5/qml-qtquick-wheelevent.html#angleDelta-prop
		wheelDelta += wheel.angleDelta.y || wheel.angleDelta.x;
		
		var increment = 0;
		
		while (wheelDelta >= 120) {
			wheelDelta -= 120;
			increment++;
		}
		
		while (wheelDelta <= -120) {
			wheelDelta += 120;
			increment--;
		}
		
		while (increment !== 0) {
			if (increment < 0) {
				var nextPage = plasmoid.configuration.wrapPage?
							(pagerModel.currentPage + 1) % pagerModel.count :
							Math.min(pagerModel.currentPage + 1, pagerModel.count - 1);
				pagerModel.changePage(nextPage);
			} else {
				var previousPage = plasmoid.configuration.wrapPage ?
							(pagerModel.count + pagerModel.currentPage - 1) % pagerModel.count :
							Math.max(pagerModel.currentPage - 1, 0);
				pagerModel.changePage(previousPage);
			}
			
			increment += (increment < 0) ? 1 : -1;
		}
	}
	
	
	Plasmoid.compactRepresentation: Item{
		Rectangle{
			id: sizeHelper
			visible: false
			anchors.fill: parent
		}
		
		PlasmaComponents.Label{
			id: sizeLbl
			//visible: false
			opacity: 1
			text: "hi"
			z: 10
			
			states: [
				State{
					name: "clicked"
					PropertyChanges {
						target: sizeLbl
						text: "clicked"
					}
				}
			]
		}
		
		
		ColorAnimation {
			id: anim
			target: sizeLbl
			from: "white"
			to: "black"
			duration: 200
		}
		
		Loader{
			id: compLoader
			
			
			
			
			x: 0
			y: (sizeHelper.height * 0.8 > PlasmaCore.Theme.defaultFont.pixelSize + 4) ? sizeHelper.height * 0.1 : 0
			height: Math.max(sizeHelper.height * 0.8, PlasmaCore.Theme.defaultFont.pixelSize + 4)
			width: sizeHelper.width
			sourceComponent: numberBox
			//color:  "green"
			onHeightChanged: console.log("new height: ", height)
			onWidthChanged: console.log("new width: ", width)
			
			Component.onCompleted: console.log("im here ------------------------------")
			
			property int _minWidth: pagerModel.currentPage >= 9 ? 2 * PlasmaCore.Units.gridUnit + 4 : PlasmaCore.Units.gridUnit + 4 
			onStateChanged:{
				console.log("state changed. new state: ", state)
				anim.running = true
//				if(state === "horizontalPanel"){
//					console.log("hor")
//					compLoader.x= 0
//					compLoader.y= (sizeHelper.height * 0.8 > PlasmaCore.Theme.defaultFont.pixelSize + 4) ? sizeHelper.height * 0.1 : 0
//					compLoader.height= Math.max(sizeHelper.height * 0.8, PlasmaCore.Theme.defaultFont.pixelSize + 4)
//					compLoader.width= sizeHelper.width
//				} else if(state === "verticalPanel"){
//					console.log("ver")
//					compLoader.x= (sizeHelper.width * 0.8 > _minWidth) ? sizeHelper.width * 0.1 : 0
//					compLoader.y= 0
//					compLoader.height= sizeHelper.height
//					compLoader.width= Math.max(sizeHelper.width * 0.8, _minWidth)
//				} else{
//					console.log("oth")
//					x= 0
//					y= 0
//					height= sizeHelper.height
//					width= sizeHelper.width
//				}
			}
			
			states: [
				State{
					name: "horizontalPanel"
					when: plasmoid.formFactor === PlasmaCore.Types.Horizontal
					
					PropertyChanges {
						target: compLoader
						x: 0
						y: (sizeHelper.height * 0.8 > PlasmaCore.Theme.defaultFont.pixelSize + 4) ? sizeHelper.height * 0.1 : 0
						height: Math.max(sizeHelper.height * 0.8, PlasmaCore.Theme.defaultFont.pixelSize + 4)
						width: sizeHelper.width
						color: "blue"
					}
				},
				
				State{
					name: "verticalPanel"
					when: plasmoid.formFactor === PlasmaCore.Types.Vertical
					
					PropertyChanges {
						target: compLoader
						property int _minWidth: pagerModel.currentPage >= 9 ? 2 * PlasmaCore.Units.gridUnit + 4 : PlasmaCore.Units.gridUnit + 4 
						x: (sizeHelper.width * 0.8 > _minWidth) ? sizeHelper.width * 0.1 : 0
						y: 0
						height: sizeHelper.height
						width: Math.max(sizeHelper.width * 0.8, _minWidth)
						color: "yellow"
					}
				},
				
				State{
					name: "other"
					when: plasmoid.formFactor !== PlasmaCore.Types.Horizontal && plasmoid.formFactor !== PlasmaCore.Types.Vertical
					
					PropertyChanges {
						target: compLoader
						x: 0
						y: 0
						height: sizeHelper.height
						width: sizeHelper.width
					}
				}
			]
		}
		
		Binding{
			target: compLoader.item
			property: "text"
			value: pagerModel.currentPage + 1
		}
		
		MouseArea{
			anchors.fill: parent
			
			onClicked: plasmoid.expanded = ! plasmoid.expanded
			//onClicked: sizeLbl.state = "clicked"
			onWheel: switchDesktop(wheel)
		}
		
		
		
	}
	
	
	Plasmoid.fullRepresentation: Item{
		Loader{
			id: fullLoader
			anchors.fill: parent
			//			Layout.preferredHeight: item.preferredHeight
			sourceComponent: numberBox
		}
		
		PlasmaComponents.Label{
			id: tstLbl
			text: "hi"
			x: 10
			y: 10
			onStateChanged: console.log("state changed. new state: ", state)
			
			states: [
				State{
					name: "clickd"
					PropertyChanges{
						target: tstLbl
						text: "clicked"
					}
				}

			]
		}
		
		Binding{
			target: fullLoader.item
			property: "text"
			value: pagerModel.currentPage + 1
		}
		
		MouseArea{
			anchors.fill: parent
			onClicked: tstLbl.state = tstLbl.state === "clickd" ? "" : "clickd"
			onWheel: switchDesktop(wheel)
		}
	}
	
	
	
	
	Component{
		id: numberBox
		
		Rectangle {			
			color: PlasmaCore.Theme.backgroundColor
			border.color: PlasmaCore.Theme.textColor
			border.width: 1
			radius: 5
			
			//			Layout.minimumHeight: numberLbl.implicitHeight + 4
			//			Layout.minimumWidth: numberLbl.implicitWidth + 4
			
			//+4 for borders and margins on both sides
			//			Layout.preferredHeight: numberLbl.implicitHeight + 4
			//			Layout.preferredWidth: numberLbl.implicitWidth + 4
			
			property alias text: numberLbl.text 
			
			PlasmaComponents.Label{
				id: numberLbl
				anchors.centerIn: parent
				color: PlasmaCore.Theme.textColor
				text: pagerModel.currentPage + 1
			}
		}
	}
	
	
	PagerModel {
		id: pagerModel
		
		enabled: true
		
		showDesktop: (plasmoid.configuration.currentDesktopSelected === 1)
		
		showOnlyCurrentScreen: plasmoid.configuration.showOnlyCurrentScreen
		screenGeometry: plasmoid.screenGeometry
		
		pagerType: PagerModel.VirtualDesktops
	}
	
	Component.onCompleted: {
		if (KQuickControlsAddonsComponents.KCMShell.authorize("kcm_kwin_virtualdesktops.desktop").length > 0) {
			plasmoid.setAction("addDesktop", i18n("Add Virtual Desktop"), "list-add");
			plasmoid.setAction("removeDesktop", i18n("Remove Virtual Desktop"), "list-remove");
			plasmoid.action("removeDesktop").enabled = Qt.binding(function() {
				return pagerModel.count > 1;
			});
			
			plasmoid.setAction("openKCM", i18n("Configure Virtual Desktops..."), "configure");
		}
	}
}
