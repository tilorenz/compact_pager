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
 * You should have received a copy of the GNU General Public License.
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
import org.kde.kcmutils as KCM
import org.kde.config as KConfig

import org.kde.plasma.plasma5support as Plasma5Support

import "./lib"

PlasmoidItem {
	id: root

	Plasmoid.status: (pagerModel.shouldShowPager || plasmoid.configuration.stayVisible) ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.HiddenStatus

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

	function runOverview() {
		executable.exec('qdbus org.kde.kglobalaccel /component/kwin invokeShortcut Overview')
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

		if (plasmoid.configuration.invertScrollDirection) {
			increment = -increment;
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

	MouseArea {
		id: rootMouseArea
		anchors.fill: parent

		onWheel: wheel => { plasmoid.configuration.enableScrolling ? switchDesktop(wheel) : {} }
	}

	preferredRepresentation: compactRepresentation
	compactRepresentation: ReprLayout {
		isFullRep: false
	}
	fullRepresentation: ReprLayout {
		isFullRep: true
	}

	PagerModel {
		id: pagerModel

		enabled: root.visible

		showDesktop: (plasmoid.configuration.currentDesktopSelected === 1)

		showOnlyCurrentScreen: plasmoid.configuration.showOnlyCurrentScreen
		screenGeometry: root.screenGeometry

		pagerType: PagerModel.VirtualDesktops
	}

	Plasma5Support.DataSource {
		id: executable
		engine: "executable"
		connectedSources: []
		onNewData: function(source, data) {
			disconnectSource(source)
		}

		function exec(cmd) {
			executable.connectSource(cmd)
		}
	}

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: "Add Virtual Desktop"
            icon.name: "list-add"
            visible: KConfig.KAuthorized.authorize("kcm_kwin_virtualdesktops")
            onTriggered: pagerModel.addDesktop()
        },
        PlasmaCore.Action {
            text: "Remove Virtual Desktop"
            icon.name: "list-remove"
            visible: KConfig.KAuthorized.authorize("kcm_kwin_virtualdesktops")
			enabled: Qt.binding(function() {
				return pagerModel.count > 1;
			});
            onTriggered: pagerModel.removeDesktop()
        },
        PlasmaCore.Action {
            text: "Configure Virtual Desktops…"
            visible: KConfig.KAuthorized.authorize("kcm_kwin_virtualdesktops")
            onTriggered: KCM.KCMLauncher.openSystemSettings("kcm_kwin_virtualdesktops")
        }
    ]
}
