import QtQuick 2.6
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddonsComponents
import org.kde.plasma.private.pager 2.0

GridLayout{
	anchors.fill: parent
	columns: Math.ceil(pagerModel.count / pagerModel.layoutRows)
	
	Repeater{
		id: dRep
		model: pagerModel
		NumberBox{
			id: nBox
			text: model.index + 1
			
			MouseArea{
				anchors.fill: parent
				onClicked: {
					pagerModel.changePage(model.index)
					//TODO maybe add option for this
					plasmoid.expanded = false
				}
			}
		}
	}
}
