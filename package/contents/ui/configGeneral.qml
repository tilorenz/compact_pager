/*
 * Copyright 2013 David Edmundson <davidedmundson@kde.org>
 * Copyright 2016  Eike Hein <hein@kde.org>
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

import QtQuick 2.5
import QtQuick.Controls 2.5 as QtControls

import org.kde.kirigami 2.5 as Kirigami


Kirigami.FormLayout {
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
	
	
	QtControls.ComboBox {
		id: pagerLayout
		
		Kirigami.FormData.label: i18n("Layout:")
		
		//TODO find a way to have the ToolTip on the elements instead of the Box. This is ugly & unintuitive.
		QtControls.ToolTip.delay: 1000
		QtControls.ToolTip.timeout: 5000
		QtControls.ToolTip.visible: hovered
		QtControls.ToolTip.text: switch(currentIndex){
								 case 0: return "Switch the layout depending on available space."
								 case 1: return "Always show full layout. Warning: looks broken if not enough space is available."
								 case 2: return "Always show compact layout."
								 }
		
		model: ["Adaptive", "Full", "Compact"]
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
