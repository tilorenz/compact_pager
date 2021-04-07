import QtQuick 2.6
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddonsComponents
import org.kde.plasma.private.pager 2.0


Item{
//	Rectangle{
//		id: sizeHelper
//		visible: false
//		anchors.fill: parent
		
//	}
	
//	PlasmaComponents.Label{
//		id: sizeLbl
//		visible: false
//	}
	
	Loader{
		id: compLoader
		x: 0
		y: (sizeHelper.height * 0.8 > PlasmaCore.Theme.defaultFont.pixelSize + 4) ? sizeHelper.height * 0.1 : 0
		height: Math.max(sizeHelper.height * 0.8, PlasmaCore.Theme.defaultFont.pixelSize + 4)
		width: sizeHelper.width
		property int _minWidth: pagerModel.currentPage >= 9 ? 2 * PlasmaCore.Units.gridUnit + 4 : PlasmaCore.Units.gridUnit + 4 
		
		sourceComponent: numberBox	
	}
	
	Binding{
		target: compLoader.item
		property: "text"
		value: pagerModel.currentPage + 1
	}
	
	MouseArea{
		anchors.fill: parent
		
		onClicked: plasmoid.expanded = ! plasmoid.expanded
		onWheel: switchDesktop(wheel)
	}
	
	states: [
		State {
			name: "horizontalPanel"
			when: plasmoid.formFactor === PlasmaCore.Types.Horizontal
			
			PropertyChanges {
				target: compLoader
				x: 0
				y: (sizeHelper.height * 0.8 > PlasmaCore.Theme.defaultFont.pixelSize + 4) ? sizeHelper.height * 0.1 : 0
				height: Math.max(sizeHelper.height * 0.8, PlasmaCore.Theme.defaultFont.pixelSize + 4)
				width: sizeHelper.width
			}
//			PropertyChanges{
//				target: sizeHelper
				
//			}
		},
		
		State {
			name: "verticalPanel"
			when: plasmoid.formFactor === PlasmaCore.Types.Vertical
			
			PropertyChanges {
				target: compLoader
				x: (sizeHelper.width * 0.8 > _minWidth) ? sizeHelper.width * 0.1 : 0
				y: 0
				height: sizeHelper.height
				width: Math.max(sizeHelper.width * 0.8, _minWidth)
			}
		},
		
		State{
			name: "other"
			when: plasmoid.formFactor !== PlasmaCore.Types.Horizontal && plasmoid.formFactor !== PlasmaCore.Types.Vertical
			
			PropertyChanges {
				target: compLoader
				x: 0
				y: 0
				height: sizeHelper.height
				width: sizeHelper.width
			}
		}
	]
}
