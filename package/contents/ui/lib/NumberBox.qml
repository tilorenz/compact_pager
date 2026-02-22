/*
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

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kquickcontrolsaddons as KQuickControlsAddonsComponents
import org.kde.kirigami as Kirigami

Rectangle {
	id: numberBox
	property alias text: numberText.text 
	property bool fontSizeChecked: plasmoid.configuration.fontSizeChecked
	property color fontColor: plasmoid.configuration.fontColorChecked ? 
			plasmoid.configuration.fontColor : Kirigami.Theme.textColor
	property bool showWindowIndicator: true
	property list<var> iconSources: []

	border.width: plasmoid.configuration.displayBorder ? plasmoid.configuration.borderThickness : 0
	radius: height > width ? height * (plasmoid.configuration.borderRadius / 100) : width * (plasmoid.configuration.borderRadius / 100)

	Text {
		id: sizeRefText
		visible: false
		// color: "red"
		text: numberBox.text
		font {
			family: plasmoid.configuration.fontFamily || Kirigami.Theme.defaultFont.family
			bold: plasmoid.configuration.fontBold
			italic: plasmoid.configuration.fontItalic
			pixelSize: fontSizeChecked ? plasmoid.configuration.fontSize : Kirigami.Theme.defaultFont.pixelSize
		}
	}

	Layout.minimumWidth: sizeRefText.width + 10
	Layout.minimumHeight: sizeRefText.height

	Layout.preferredWidth: sizeRefText.width + 10
	Layout.preferredHeight: sizeRefText.height

	Layout.fillWidth: Plasmoid.formFactor != PlasmaCore.Types.Horizontal
	Layout.fillHeight: Plasmoid.formFactor != PlasmaCore.Types.Vertical

	Rectangle {
		id: windowIndicator
		visible: numberBox.showWindowIndicator

		anchors.left: numberText.right
		anchors.top: numberText.top

		width: 8
		height: 8
		border.color: numberBox.fontColor
		border.width: 1
		color: "transparent"
		radius: width * (plasmoid.configuration.windowIndicatorRadius / 100)
	}

	Text {
		id: numberText
		visible: !plasmoid.configuration.showWindowIcons

		anchors.centerIn: parent
		width: parent.width - 10
		height: parent.height
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter

		color: fontColor
		font {
			family: plasmoid.configuration.fontFamily || Kirigami.Theme.defaultFont.family
			bold: plasmoid.configuration.fontBold
			italic: plasmoid.configuration.fontItalic
			pixelSize: fontSizeChecked ? plasmoid.configuration.fontSize : 999
		}
		fontSizeMode: fontSizeChecked ? Text.FixedSize : Text.Fit
		minimumPixelSize: Kirigami.Theme.smallFont.pixelSize
	}

	Grid {
		id: iconGrid
		anchors.centerIn: parent
		visible: plasmoid.configuration.showWindowIcons

		readonly property int maxIconCount: Math.floor(Math.max(numberBox.height, numberBox.width) / iconSize)
		readonly property bool showIconsInColumn: numberBox.height > numberBox.width
		readonly property bool showAllIcons: numberBox.iconSources.length <= maxIconCount
		readonly property int iconSize: Math.min(numberBox.height * 0.7, numberBox.width * 0.7)

		columns: (showIconsInColumn || !showAllIcons) ? 1 : maxIconCount
		rows: (showIconsInColumn && showAllIcons) ? maxIconCount : 1
		flow: showIconsInColumn ? Grid.TopToBottom : Grid.LeftToRight

		component BoxIcon: Kirigami.Icon {
			height: iconGrid.iconSize
			width: iconGrid.iconSize
			roundToIconSize: false
		}

		Repeater {
			model: numberBox.iconSources
			BoxIcon {
				visible: iconGrid.showAllIcons
				source: modelData
			}
		}

		BoxIcon {
			visible: !iconGrid.showAllIcons
			source: iconGrid.showIconsInColumn ? "view-more-symbolic" : "view-more-horizontal-symbolic"
		}
	}

}
