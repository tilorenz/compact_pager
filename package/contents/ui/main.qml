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

import org.kde.taskmanager
import org.kde.kcmutils as KCM
import org.kde.config as KConfig

import org.kde.plasma.plasma5support as Plasma5Support

import "./lib"

PlasmoidItem {
	id: root

	property int wheelDelta: 0

	function action_addDesktop() {
		let desktopCount = pagerModel.numberOfDesktops
		// if there are 3 desktops, create the new one at the end with name "Desktop 4"
		executable.exec(`qdbus6 org.kde.kglobalaccel /VirtualDesktopManager createDesktop ${desktopCount} "Desktop ${desktopCount + 1}"`)
	}

	function action_removeDesktop() {
		// TODO pretty sure this has always worked by removing the last desktop, but we probably should make the
		// context menu aware of which one was clicked (at least in full representation) and remove that one?
		let lastDesktopId = pagerModel.desktopIds[pagerModel.numberOfDesktops - 1]
		executable.exec(`qdbus6 org.kde.kglobalaccel /VirtualDesktopManager removeDesktop ${lastDesktopId}`)
	}

	function action_openKCM() {
		KQuickControlsAddonsComponents.KCMShell.openSystemSettings("kcm_kwin_virtualdesktops");
	}

	function runOverview() {
		executable.exec('qdbus6 org.kde.kglobalaccel /component/kwin invokeShortcut Overview')
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

		let isOnFirstDesktop = pagerModel.currentDesktop === pagerModel.desktopIds[0]
		let isOnLastDesktop = pagerModel.currentDesktop === pagerModel.desktopIds[pagerModel.numberOfDesktops - 1]

		while (increment !== 0) {
			if (increment < 0) {
				if (plasmoid.configuration.wrapPage || !isOnLastDesktop) {
					executable.exec(`qdbus6 org.kde.kglobalaccel /KWin nextDesktop`)
				}
			} else {
				if (plasmoid.configuration.wrapPage || !isOnFirstDesktop) {
					executable.exec(`qdbus6 org.kde.kglobalaccel /KWin previousDesktop`)
				}
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

	VirtualDesktopInfo {
		id: pagerModel
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
            onTriggered: action_addDesktop()
        },
        PlasmaCore.Action {
            text: "Remove Virtual Desktop"
            icon.name: "list-remove"
            visible: KConfig.KAuthorized.authorize("kcm_kwin_virtualdesktops")
			enabled: Qt.binding(function() {
				return pagerModel.numberOfDesktops > 1;
			});
            onTriggered: action_removeDesktop()
        },
        PlasmaCore.Action {
            text: "Configure Virtual Desktops…"
            visible: KConfig.KAuthorized.authorize("kcm_kwin_virtualdesktops")
            onTriggered: KCM.KCMLauncher.openSystemSettings("kcm_kwin_virtualdesktops")
        }
    ]
}
