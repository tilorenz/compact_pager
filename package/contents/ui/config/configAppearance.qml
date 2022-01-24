/*
 * Copyright 2013  Heena Mahour <heena393@gmail.com>
 * Copyright 2013  Sebastian Kügler <sebas@kde.org>
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
import QtQuick.Controls 1.0 as QtControls1
import QtQuick.Controls 2.5 as QtControls
import QtQuick.Layouts 1.15 as QtLayouts

import org.kde.kirigami 2.5 as Kirigami
import org.kde.kquickcontrols 2.0 as KQControls
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3

Kirigami.FormLayout {
	id: layoutAppearance

	anchors.left: parent.left
	anchors.right: parent.right

	property string cfg_fontFamily
	property alias cfg_fontBold: boldCheckBox.checked
	property alias cfg_fontItalic: italicCheckBox.checked
	property alias cfg_fontColor: fontColorValue.color
	property alias cfg_fontColorChecked: fixedFontColor.checked
	property alias cfg_fontSizeChecked: fontSize.checked
	property alias cfg_fontSize: fontSizeValue.value
	property alias cfg_displayBorder: displayBorder.checked
	property alias cfg_borderColor: borderColor.color
	property alias cfg_sameBorderColorAsFont: sameColorAsFont.checked
	property alias cfg_borderThickness: borderThickness.value
	property alias cfg_borderRadius: borderRadius.value
	property alias cfg_bgColorChecked: fixedBGColor.checked
	property alias cfg_bgColor: bgColorValue.color


	// Taken from org.kde.plasma.digitalclock
	// See: https://phabricator.kde.org/source/plasma-workspace/browse/master/applets/digital-clock/
	onCfg_fontFamilyChanged: {
		// HACK by the time we populate our model and/or the ComboBox is finished the value is still undefined
		if (cfg_fontFamily) {
			for (var i = 0, j = fontsModel.count; i < j; ++i) {
				if (fontsModel.get(i).value === cfg_fontFamily) {
					fontFamily.currentIndex = i
					break
				}
			}
		}
	}

	ListModel {
		id: fontsModel
		Component.onCompleted: {
			var arr = [] // use temp array to avoid constant binding stuff
			arr.push({text: i18n("Default"), value: ""})

			var fonts = Qt.fontFamilies()
			var foundIndex = 0
			for (var i = 0, j = fonts.length; i < j; ++i) {
				arr.push({text: fonts[i], value: fonts[i]})
			}
			append(arr)
		}
	}

	//
	// FONT
	//
	Item {
		Kirigami.FormData.isSection: true
		Kirigami.FormData.label: i18n("Font")
	}

	QtLayouts.RowLayout {
		QtLayouts.Layout.fillWidth: true

		Kirigami.FormData.label: i18n("Font style:")

		// Based on org.kde.plasma.digitalclock
		QtControls.ComboBox {
			id: fontFamily
			QtLayouts.Layout.fillWidth: true
			currentIndex: 0
			// ComboBox's sizing is just utterly broken
			QtLayouts.Layout.minimumWidth: units.gridUnit * 10
			model: fontsModel
			// Doesn't autodeduce from model because we manually populate it
			textRole: "text"

			onCurrentIndexChanged: {
				var current = model.get(currentIndex)
				if (current) {
					cfg_fontFamily = current.value
				}
			}
		}

		QtControls.Button {
			id: boldCheckBox
			icon.name: "format-text-bold"
			checkable: true
			QtControls.ToolTip { text: i18n("Bold text") }
			Accessible.name: QtControls.ToolTip.text
		}

		QtControls.Button {
			id: italicCheckBox
			icon.name: "format-text-italic"
			checkable: true
			QtControls.ToolTip { text: i18n("Italic text") }
			Accessible.name: QtControls.ToolTip.text
		}
	}

	QtLayouts.RowLayout {
		QtLayouts.Layout.fillWidth: true
		Kirigami.FormData.label: i18n("Fixed font size:")

		QtControls.CheckBox {
			id: fontSize
		}

		QtControls1.SpinBox { // SpinBox in Controls 2.5 doesn't provide "suffix"
			id: fontSizeValue
			enabled: fontSize.checked
			minimumValue: 1
			stepSize: 1
			suffix: " " + i18n("px")
		}
	}

	QtLayouts.RowLayout {
		QtLayouts.Layout.fillWidth: true
		Kirigami.FormData.label: i18n("Fixed font color:")

		QtControls.CheckBox {
			id: fixedFontColor
		}

		KQControls.ColorButton {
			id: fontColorValue
			enabled: fixedFontColor.checked
			Kirigami.FormData.label: i18n("Font color:")
			showAlphaChannel: true
			onColorChanged: {
				if (sameColorAsFont.checked) {
					borderColor.color = fontColor.color
				}
			}
		}
	}

	Kirigami.Separator {
		Kirigami.FormData.isSection: true
		Kirigami.FormData.label: i18n("Border")
	}

	QtControls.CheckBox {
		id: displayBorder
		Kirigami.FormData.label: i18n("Show border:")
	}

	QtLayouts.RowLayout {
		QtLayouts.Layout.fillWidth: true
		Kirigami.FormData.label: i18n("Border color:")
		spacing: PlasmaCore.Units.largeSpacing

		KQControls.ColorButton {
			id: borderColor
			enabled: displayBorder.checked && !sameColorAsFont.checked
			showAlphaChannel: true
		}


		QtControls.CheckBox {
			id: sameColorAsFont
			text: i18n("Same as font")
		}
	}

	QtControls1.SpinBox { // SpinBox in Controls 2.5 doesn't provide "suffix"
		id: borderThickness
		enabled: displayBorder.checked
		Kirigami.FormData.label: i18n("Border thickness:")
		minimumValue: 1
		stepSize: 1
		suffix: " " + i18n("px")
	}

	QtControls1.SpinBox { // SpinBox in Controls 2.5 doesn't provide "suffix"
		id: borderRadius
		enabled: displayBorder.checked
		Kirigami.FormData.label: i18n("Border radius:")
		minimumValue: 0
		maximumValue: 100
		stepSize: 1
		suffix: " " + i18n("%")
	}

	Kirigami.Separator {
		Kirigami.FormData.isSection: true
		Kirigami.FormData.label: i18n("Background")
	}

	QtLayouts.RowLayout {
		QtLayouts.Layout.fillWidth: true
		Kirigami.FormData.label: i18n("Fixed background color:")

		QtControls.CheckBox {
			id: fixedBGColor
		}

		KQControls.ColorButton {
			id: bgColorValue
			showAlphaChannel: true
			enabled: fixedBGColor.checked
		}
	}
}
