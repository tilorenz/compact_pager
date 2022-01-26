/*
 * Copyright 2012  Luís Gabriel Lima <lampih@gmail.com>
 * Copyright 2016  Kai Uwe Broulik <kde@privat.broulik.de>
 * Copyright 2016  Eike Hein <hein@kde.org>
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

import "./lib"

Item {
	id: root

	Plasmoid.switchHeight: switch(plasmoid.configuration.forceLayout) {
							   case 0: return Math.floor(pagerModel.layoutRows) * PlasmaCore.Units.gridUnit
							   case 1: return 0.1 * PlasmaCore.Units.gridUnit //full
							   case 2: return 500 * PlasmaCore.Units.gridUnit //compactu
						   }

	Plasmoid.switchWidth: switch(plasmoid.configuration.forceLayout) {
							   case 0: return Math.floor(1.4 * pagerModel.count / pagerModel.layoutRows) * PlasmaCore.Units.gridUnit
							   case 1: return 0.1 * PlasmaCore.Units.gridUnit //full
							   case 2: return 500 * PlasmaCore.Units.gridUnit //compact
						  }

	Plasmoid.status: pagerModel.shouldShowPager ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.HiddenStatus

	property int wheelDelta: 0

	function action_addDesktop() {
		pagerModel.addDesktop();
	}

	function action_removeDesktop() {
		pagerModel.removeDesktop();
	}

	function action_openKCM() {
		KQuickControlsAddonsComponents.KCMShell.openSystemSettings("kcm_kwin_virtualdesktops");
	}

	function switchDesktop(wheel) {
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
				var nextPage = plasmoid.configuration.wrapPage ?
									(pagerModel.currentPage + 1) % pagerModel.count :
									Math.min(pagerModel.currentPage + 1, pagerModel.count - 1);
				if(nextPage !== pagerModel.currentPage)
					pagerModel.changePage(nextPage);
			} else {
				var previousPage = plasmoid.configuration.wrapPage ?
										(pagerModel.count + pagerModel.currentPage - 1) % pagerModel.count :
										Math.max(pagerModel.currentPage - 1, 0);
				if(previousPage !== pagerModel.currentPage)
					pagerModel.changePage(previousPage);
			}

			increment += (increment < 0) ? 1 : -1;
		}
	}

	Plasmoid.compactRepresentation: CRep { }

	Plasmoid.fullRepresentation: FRep { }

	PagerModel {
		id: pagerModel

		enabled: root.visible

		showDesktop: (plasmoid.configuration.currentDesktopSelected === 1)

		showOnlyCurrentScreen: false
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
