/*
 * Copyright 2013  David Edmundson <davidedmundson@kde.org>
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

import QtQuick 2.5
import QtQuick.Controls 2.5 as QtControls
import QtQuick.Layouts 1.15 as QtLayouts

import org.kde.kirigami 2.5 as Kirigami

Kirigami.FormLayout {
	id: layoutGeneral

	anchors.left: parent.left
	anchors.right: parent.right

	property alias cfg_forceLayout: pagerLayout.currentIndex
	property alias cfg_wrapPage: wrapPage.checked
	property alias cfg_currentDesktopSelected: currentDesktopSelectedBox.currentIndex

	QtControls.CheckBox {
		id: wrapPage
		text: i18n("Navigation wraps around")
	}

	Item {
		Kirigami.FormData.isSection: true
	}

	QtLayouts.RowLayout {
		QtLayouts.Layout.fillWidth: true

		Kirigami.FormData.label: i18n("Layout:")
		QtControls.ComboBox {
			id: pagerLayout
			model: ["Adaptive", "Full", "Compact"]
		}

		QtControls.Button {
			id: infoButton
			icon.name: "dialog-information"
			QtControls.ToolTip.visible: hovered
			QtControls.ToolTip.text: "<b>Adaptive</b>:<br>Switch the layout depending on available space.<br><br>" +
			                         "<b>Full</b>:<br>Always show full layout.<br><br>" +
									 "<b>Compact</b>:<br>Always show compact layout."
		}
	}

	Item {
		Kirigami.FormData.isSection: true
	}

	QtControls.ComboBox {
		id: currentDesktopSelectedBox
		Kirigami.FormData.label: i18n("Selecting current virtual desktop:")

		model: ["Does nothing", "Shows the desktop"]
	}
}
