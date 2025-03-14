/**
 *  OSM
 *  Copyright (C) 2018  Pavel Smokotnin

 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 2.7
import QtQuick.Controls 2.2
import FftChart 1.0
import QtQuick.Controls.Material 2.2

Item {
    id: chartview
    property alias type: chart.type
    property alias settings: chart.settings

    VariableChart {
        id: chart
        anchors.fill: parent
        sources: sourceList

        Component.onCompleted: {
            initOpener();
        }

        onTypeChanged: function() {
            initOpener();
        }

        function initOpener() {
            opener.propertiesQml = null;
            switch(type) {
            case "RTA":
                opener.propertiesQml = "qrc:/Plot/RTAProperties.qml";
                break;
            case "Magnitude":
                opener.propertiesQml = "qrc:/Plot/MagnitudeProperties.qml";
                break;
            case "Phase":
                opener.propertiesQml = "qrc:/Plot/PhaseProperties.qml";
                break;
            case "Impulse":
                opener.propertiesQml = "qrc:/Plot/ImpulseProperties.qml";
                break;
            case "Coherence":
                opener.propertiesQml = "qrc:/Plot/CoherenceProperties.qml";
                break;
            }
        }
    }

    PropertiesOpener {
        id: opener
        pushObject: chart.plot;
        cursorShape: "CrossCursor";
        hoverEnabled: true
        onEntered: cursor.visible = true
        onExited: cursor.visible = false
    }

    Label {
        id: cursor
        text: "%1".arg(chart.plot.y2v(opener.mouseY)) + "\n" + "%1".arg(chart.plot.x2v(opener.mouseX))
        x: opener.mouseX + cursor.fontInfo.pixelSize / 2
        y: opener.mouseY - cursor.height / 2
        visible: opener.containsMouse
    }

    ComboBox {
        anchors.top: parent.top
        anchors.right: parent.right
        implicitWidth: 135
        implicitHeight: Material.buttonHeight
        background: null
        model: ["RTA", "Magnitude", "Phase", "Impulse", "Coherence"]
        currentIndex: model.indexOf(type)
        onCurrentIndexChanged: {
            var pb = applicationWindow.properiesbar;
            var reopen = false;
            if (pb.currentObject == chart.plot) {
                pb.reset();
                reopen = true;
            }
            chart.type = model[currentIndex];
            if (reopen) {
                pb.open(chart.plot, opener.propertiesQml);
            }
        }
        Component.onCompleted: {
            chart.type = model[currentIndex];
        }
    }
}
