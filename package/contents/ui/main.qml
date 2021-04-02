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

import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddonsComponents
import org.kde.plasma.private.pager 2.0
import org.kde.plasma.activityswitcher 1.0 as ActivitySwitcher

Rectangle {
	id: root
	
	property bool isActivityPager: (plasmoid.pluginName === "sap")
	
	color: PlasmaCore.Theme.backgroundColor
	border.color: PlasmaCore.Theme.textColor
	border.width: 1
	radius: 5
	
	Layout.minimumHeight: mainLbl.implicitHeight
	Layout.minimumWidth: mainLbl.implicitWidth
	
//	Layout.preferredHeight: Math.max(Layout.minimumHeight, units.gridUnit)
//	Layout.preferredWidth: Math.max(Layout.minimumWidth, units.gridUnit)
	
	
	Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation
	Plasmoid.status: pagerModel.shouldShowPager ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.HiddenStatus
	
	property int wheelDelta: 0
	
	//anchors.fill: parent
	
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
	
	function action_showActivityManager() {
		ActivitySwitcher.Backend.toggleActivityManager()
	}
	
	PlasmaComponents.Label{
		id: mainLbl
		anchors.centerIn: parent
		color: PlasmaCore.Theme.textColor
		text: isActivityPager ? pagerModel.TasksModel.activity : pagerModel.currentPage		
	}
	
	MouseArea{
		anchors.fill: parent
		
		onWheel: {
			console.log("angleDelta y: ", wheel.angleDelta.y, " x: ", wheel.angleDelta.x)
			console.log("current page: ", pagerModel.currentPage, " count: ", pagerModel.count)

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
	}
	
	
	PagerModel {
		id: pagerModel
		
		enabled: root.visible
		
		showDesktop: (plasmoid.configuration.currentDesktopSelected === 1)
		
		showOnlyCurrentScreen: plasmoid.configuration.showOnlyCurrentScreen
		screenGeometry: plasmoid.screenGeometry
		
		pagerType: isActivityPager ? PagerModel.Activities : PagerModel.VirtualDesktops
	}
	
	Component.onCompleted: {
		if (isActivityPager) {
			plasmoid.setAction("showActivityManager", i18n("Show Activity Manager..."), "activities");
		} else {
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
}
