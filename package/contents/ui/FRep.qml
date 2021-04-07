import QtQuick 2.6
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddonsComponents
import org.kde.plasma.private.pager 2.0

Item{
	Loader{
		id: fullLoader
		anchors.fill: parent
		//			Layout.preferredHeight: item.preferredHeight
		sourceComponent: numberBox
	}
	
	Binding{
		target: fullLoader.item
		property: "text"
		value: pagerModel.currentPage + 1
	}
	
	MouseArea{
		anchors.fill: parent
		onWheel: switchDesktop(wheel)
	}
}
