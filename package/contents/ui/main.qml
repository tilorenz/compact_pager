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
import org.kde.plasma.workspace.dbus as DBus
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
		DBus.SessionBus.asyncCall({
			"service": "org.kde.kglobalaccel",
			"path": "/VirtualDesktopManager",
			"iface": "org.kde.KWin.VirtualDesktopManager",
			"member": "createDesktop",
			"arguments": [
				// if there are 3 desktops, create the new one at the end with name "Desktop 4"
				new DBus.uint32(desktopCount),
				new DBus.string("New Desktop")
			],
		})
	}

	function action_removeDesktop() {
		// TODO pretty sure this has always worked by removing the last desktop, but we probably should make the
		// context menu aware of which one was clicked (at least in full representation) and remove that one?
		let lastDesktopId = pagerModel.desktopIds[pagerModel.numberOfDesktops - 1]
		DBus.SessionBus.asyncCall({
			"service": "org.kde.kglobalaccel",
			"path": "/VirtualDesktopManager",
			"iface": "org.kde.KWin.VirtualDesktopManager",
			"member": "removeDesktop",
			"arguments": [
				// This might not work under X11, as desktop IDs are unit there
				new DBus.string(lastDesktopId)
			],
		})
	}

	function action_openKCM() {
		KQuickControlsAddonsComponents.KCMShell.openSystemSettings("kcm_kwin_virtualdesktops");
	}

	function runOverview() {
		DBus.SessionBus.asyncCall({
			"service": "org.kde.kglobalaccel",
			"path": "/component/kwin",
			"iface": "org.kde.kglobalaccel.Component",
			"member": "invokeShortcut",
			"arguments": [
				new DBus.string("Overview")
			],
		})
	}

	function showDesktop() {
		// using the shortcut rather than the method of kwin itself as this has no argument and
		// always toggles the effect
		DBus.SessionBus.asyncCall({
			"service": "org.kde.kglobalaccel",
			"path": "/component/kwin",
			"iface": "org.kde.kglobalaccel.Component",
			"member": "invokeShortcut",
			"arguments": [
				new DBus.string("Show Desktop")
			],
		})
	}

	// index is 1-based, like in the DBus method
	function setCurrentDesktop(index) {
		DBus.SessionBus.asyncCall({
			"service": "org.kde.KWin",
			"path": "/KWin",
			"iface": "org.kde.KWin",
			"member": "setCurrentDesktop",
			"arguments": [
				new DBus.int32(index)
			],
		})
	}

	function nextDesktop() {
		DBus.SessionBus.asyncCall({
			"service": "org.kde.kglobalaccel",
			"path": "/KWin",
			"iface": "org.kde.KWin",
			"member": "nextDesktop",
		})
	}

	function previousDesktop() {
		DBus.SessionBus.asyncCall({
			"service": "org.kde.kglobalaccel",
			"path": "/KWin",
			"iface": "org.kde.KWin",
			"member": "previousDesktop",
		})
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
					nextDesktop()
				}
			} else {
				if (plasmoid.configuration.wrapPage || !isOnFirstDesktop) {
					previousDesktop()
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

	ActivityInfo {
		id: activityModel
	}

	TasksModel {
		id: mainTasksModel
		filterByVirtualDesktop: false
		groupMode: TasksModel.GroupDisabled
	}

	// maps window IDs to a model index of mainTasksModel. Needed to move DnD'd windows to virtual desktops.
	property var windowIdToModelIdx: {
		// when using a map, IDs aren't found despite the strings being identical.
		// seems to be a problem with the equivalence check the map uses.
		const result = [];
		// unfortunately, there doesn't seem to be a way to query the roles from QML, or get data by role name
		// other than using a proxy repeater.
		// see libtaskmanager/abstracttasksmodel.h
		const WIN_ID_LIST_ROLE = 262
		for (let i = 0; i < mainTasksModel.count; i++) {
			let modelIdx = mainTasksModel.index(i, 0)
			// this is a window id list like [{7274ba31-f9eb-437c-be86-213000be637c}]
			var md = modelIdx.data(WIN_ID_LIST_ROLE)
			if (md.length != 1) {
				console.warn("Compact Pager: got != 1 mime data", md)
				continue
			}
			const windowId = md[0]
			// console.log("Window ", i, "has windowId ", windowId)
			result.push([windowId, modelIdx])
		}
		return result;
	}

	function modevWindowToDesktop(windowId, desktopId) {
		var modelIdx
		for (const idToIdx of windowIdToModelIdx) {
			if (idToIdx[0] == windowId) {
				modelIdx = idToIdx[1]
			}
		}
		if (modelIdx) {
			mainTasksModel.requestVirtualDesktops(modelIdx, [desktopId])
		} else {
			console.warn("Compact Pager: Tried to move window with unknown ID to desktop. windowId:", windowId, "wi2mi:", windowIdToModelIdx)
		}
	}

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18n("Add Virtual Desktop")
            icon.name: "list-add"
            visible: KConfig.KAuthorized.authorize("kcm_kwin_virtualdesktops")
            onTriggered: action_addDesktop()
        },
        PlasmaCore.Action {
            text: i18n("Remove Virtual Desktop")
            icon.name: "list-remove"
            visible: KConfig.KAuthorized.authorize("kcm_kwin_virtualdesktops")
			enabled: Qt.binding(function() {
				return pagerModel.numberOfDesktops > 1;
			});
            onTriggered: action_removeDesktop()
        },
        PlasmaCore.Action {
            text: i18n("Configure Virtual Desktops…")
            visible: KConfig.KAuthorized.authorize("kcm_kwin_virtualdesktops")
            onTriggered: KCM.KCMLauncher.openSystemSettings("kcm_kwin_virtualdesktops")
        }
    ]
}
