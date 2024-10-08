/*
 * Copyright 2013  Heena Mahour <heena393@gmail.com>
 * Copyright 2013  Sebastian Kügler <sebas@kde.org>
 * Copyright 2021-2024  Tino Lorenz <tilrnz@gmx.net>
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
import QtQuick.Controls as QtControls
import QtQuick.Layouts as QtLayouts

import org.kde.kquickcontrols as KQControls
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
	id: layoutAppearanceRoot

	property alias cfg_fontFamily: layoutAppearance.cfg_fontFamily
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
	property alias cfg_activeBgColorChecked: fixedActiveBGColor.checked
	property alias cfg_activeBgColor: activeBgColorValue.color
	property alias cfg_inactiveBgColorChecked: fixedInactiveBGColor.checked
	property alias cfg_inactiveBgColor: inactiveBgColorValue.color
	property alias cfg_inactiveBgColorWithoutWindowsChecked: fixedInactiveBGColorWithoutWindows.checked
	property alias cfg_inactiveBgColorWithoutWindows: inactiveBgColorWithoutWindowsValue.color
	property alias cfg_showWindowIndicator: showWindowIndicator.checked
	property alias cfg_windowIndicatorRadius: windowIndicatorRadius.value

	Kirigami.FormLayout {
		id: layoutAppearance

		//anchors.left: parent.left
		//anchors.right: parent.right

		property string cfg_fontFamily

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
				QtLayouts.Layout.minimumWidth: Kirigami.Units.gridUnit * 10
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

			QtControls.SpinBox {
				id: fontSizeValue
				enabled: fontSize.checked
				from: 1
				stepSize: 1
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
			spacing: Kirigami.Units.largeSpacing

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

		QtControls.SpinBox {
			id: borderThickness
			enabled: displayBorder.checked
			Kirigami.FormData.label: i18n("Border thickness:")
			from: 1
			stepSize: 1
		}

		QtControls.SpinBox {
			id: borderRadius
			enabled: displayBorder.checked
			Kirigami.FormData.label: i18n("Border radius (%):")
			from: 0
			to: 100
			stepSize: 1
		}

		Kirigami.Separator {
			Kirigami.FormData.isSection: true
			Kirigami.FormData.label: i18n("Background")
		}

		QtLayouts.RowLayout {
			QtLayouts.Layout.fillWidth: true
			Kirigami.FormData.label: i18n("Fixed active background color:")

			QtControls.CheckBox {
				id: fixedActiveBGColor
			}

			KQControls.ColorButton {
				id: activeBgColorValue
				showAlphaChannel: true
				enabled: fixedActiveBGColor.checked
			}
		}

		QtLayouts.RowLayout {
			QtLayouts.Layout.fillWidth: true
			Kirigami.FormData.label: i18n("Fixed inactive background color:")

			QtControls.CheckBox {
				id: fixedInactiveBGColor
			}

			KQControls.ColorButton {
				id: inactiveBgColorValue
				showAlphaChannel: true
				enabled: fixedInactiveBGColor.checked
			}
		}

		QtLayouts.RowLayout {
			QtLayouts.Layout.fillWidth: true
			Kirigami.FormData.label: i18n("Fixed inactive background color without windows:")

			QtControls.CheckBox {
				id: fixedInactiveBGColorWithoutWindows
			}

			KQControls.ColorButton {
				id: inactiveBgColorWithoutWindowsValue
				showAlphaChannel: true
				enabled: fixedInactiveBGColorWithoutWindows.checked
			}
		}

		Kirigami.Separator {
			Kirigami.FormData.isSection: true
			Kirigami.FormData.label: i18n("Window Indicator")
		}

		QtControls.CheckBox {
			id: showWindowIndicator
			Kirigami.FormData.label: i18n("Show window indicator:")
		}

		QtControls.SpinBox {
			id: windowIndicatorRadius
			enabled: showWindowIndicator.checked
			Kirigami.FormData.label: i18n("Window indicator border radius (%):")
			from: 0
			to: 100
			stepSize: 1
		}
	}
}
