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
import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2
import QtQuick.Controls.Material 2.13

import Measurement 1.0

Item {
    property var dataObject

    ColumnLayout {
        spacing: 0
        anchors.fill: parent

        RowLayout {

            ComboBox {
                id: averageType
                implicitWidth: 120
                model: ["off", "LPF", "FIFO"]
                currentIndex: dataObject.averageType
                ToolTip.visible: hovered
                ToolTip.text: qsTr("average type")
                onCurrentIndexChanged: dataObject.averageType = currentIndex;
            }

            SpinBox {
                implicitWidth: 120
                value: dataObject.average
                from: 1
                to: 100
                editable: true
                onValueChanged: dataObject.average = value

                ToolTip.visible: hovered
                ToolTip.text: qsTr("average count")

                visible: dataObject.averageType === Measurement.FIFO;
            }

            ComboBox {
                implicitWidth: 120
                model: [ "0.25Hz", "0.5Hz", "1Hz" ]
                currentIndex: dataObject.filtersFrequency
                onCurrentIndexChanged: dataObject.filtersFrequency = currentIndex;

                ToolTip.visible: hovered
                ToolTip.text: qsTr("LPF frequency")

                visible: dataObject.averageType === Measurement.LPF;
            }

            Rectangle {
                implicitWidth: 120
                visible: dataObject.averageType === Measurement.OFF;
            }

            CheckBox {
                id: calibrateOn
                text: qsTr("calibrate")
                implicitWidth: 85
                checked: dataObject.calibration
                onCheckStateChanged: {
                    if (checked) {
                        if (dataObject.calibrationLoaded) {
                            dataObject.calibration = checked;
                        } else {
                            openCalibrationFileDialog.open();
                        }
                    } else {
                        dataObject.calibration = false;
                    }
                }

                ToolTip.visible: hovered
                ToolTip.text: qsTr("apply calibration")

                contentItem: Text {
                    leftPadding: calibrateOn.indicator && !calibrateOn.mirrored ? calibrateOn.indicator.width + calibrateOn.spacing : 0
                    rightPadding: calibrateOn.indicator && calibrateOn.mirrored ? calibrateOn.indicator.width + calibrateOn.spacing : 0
                    text: calibrateOn.text
                    font: calibrateOn.font
                    color: calibrateOn.enabled ? calibrateOn.Material.foreground : calibrateOn.Material.hintTextColor
                    elide: Text.ElideNone
                    verticalAlignment: Text.AlignVCenter
                }
            }
            Button {
                implicitWidth: 30
                flat: true
                spacing: 0
                text: "..."
                onClicked: {openCalibrationFileDialog.open();}
                ToolTip.visible: hovered
                ToolTip.text: qsTr("open calibration file")
            }
            FileDialog {
                id: openCalibrationFileDialog
                selectExisting: true
                title: qsTr("Please choose a file's name")
                folder: shortcuts.home
                onAccepted: function() {
                    if (dataObject.loadCalibrationFile(openCalibrationFileDialog.fileUrl)) {
                        dataObject.calibration = true;
                    } else {
                        dataObject.calibration = false;
                    }
                }
                onRejected: {
                    dataObject.calibration = false;
                    calibrateOn.checked = dataObject.calibration;
                }
            }

            CheckBox {
                text: qsTr("polarity")
                implicitWidth: 120
                checked: dataObject.polarity
                onCheckStateChanged: dataObject.polarity = checked

                ToolTip.visible: hovered
                ToolTip.text: qsTr("inverse polarity at measurement chanel")
            }

            ColorPicker {
                id: colorPicker
                Layout.preferredWidth: 25
                Layout.preferredHeight: 25
                Layout.margins: 0

                onColorChanged: {
                    dataObject.color = color
                }

                Component.onCompleted: {
                    color = dataObject.color
                }
                ToolTip.visible: hovered
                ToolTip.text: qsTr("series color")
            }

            TextField {
                id:titleField
                placeholderText: qsTr("title")
                text: dataObject.name
                onTextEdited: dataObject.name = text
                implicitWidth: 100
                ToolTip.visible: hovered
                ToolTip.text: qsTr("title")
                Layout.alignment: Qt.AlignVCenter
            }

            RowLayout {
                Layout.fillWidth: true
            }

            SpinBox {
                id: delaySpin
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: 90
                value: dataObject.delay
                implicitHeight: titleField.implicitHeight
                from: 0
                to: 48000
                editable: true
                spacing: 0
                down.indicator.width: 0
                up.indicator.width: 0
                onValueChanged: dataObject.delay = value

                textFromValue: function(value, locale) {
                    return Number(1000 * value / dataObject.sampleRate).toLocaleString(locale, 'f', 2) + "ms";
                }

                valueFromText: function(text, locale) {
                    return Number.fromLocaleString(locale, text.replace("ms", "")) * dataObject.sampleRate / 1000;
                }

                ToolTip.visible: hovered
                ToolTip.text: qsTr("estimated delay time: <b>%L1ms</b>")
                    .arg(Number(1000 * dataObject.estimated / dataObject.sampleRate).toLocaleString(locale, 'f', 2));
            }

            Button {
                text: qsTr("E");
                onClicked: {
                    delaySpin.value = dataObject.estimated;
                }
                ToolTip.visible: hovered
                ToolTip.text: qsTr("apply estimated delay")
            }
        }

        RowLayout {
            Layout.fillWidth: true

            ComboBox {
                id: powerSelect
                model: [10, 12, 14, 15, 16]
                currentIndex: { model.indexOf(dataObject.fftPower) }
                onCurrentIndexChanged: dataObject.fftPower = model[currentIndex]
                displayText: "Power:" + currentText
                ToolTip.visible: hovered
                ToolTip.text: qsTr("FFT Size: power of 2")
            }

            ComboBox {
                id: windowSelect
                model: dataObject.windows
                currentIndex: dataObject.window
                onCurrentIndexChanged: dataObject.window = currentIndex
                ToolTip.visible: hovered
                ToolTip.text: qsTr("window function")
            }

            ComboBox {
                model: dataObject.chanelsCount
                currentIndex: dataObject.dataChanel
                onCurrentIndexChanged: dataObject.dataChanel = currentIndex
                displayText: "M ch:" + (currentIndex + 1)
                delegate: ItemDelegate {
                          text: modelData + 1
                          width: parent.width
                      }
                ToolTip.visible: hovered
                ToolTip.text: qsTr("measurement chanel number")
            }

            ComboBox {
                model: dataObject.chanelsCount
                currentIndex: dataObject.referenceChanel
                onCurrentIndexChanged: dataObject.referenceChanel = currentIndex
                displayText: "R ch:" + (currentIndex + 1)
                delegate: ItemDelegate {
                          text: modelData + 1
                          width: parent.width
                      }
                ToolTip.visible: hovered
                ToolTip.text: qsTr("reference chanel number")
            }

            ComboBox {
                id: deviceSelect
                Layout.fillWidth: true
                model: dataObject.devices
                currentIndex: { model.indexOf(dataObject.device) }
                onCurrentIndexChanged: {
                    dataObject.device = model[currentIndex]
                }
                ToolTip.visible: hovered
                ToolTip.text: qsTr("audio input device")
                displayText: dataObject.device
            }

            Button {
                text: qsTr("Store");
                onClicked: {
                    var stored = dataObject.store();
                    stored.name = 'Stored #' + (sourceList.count - 0);
                    stored.active = true;
                    sourceList.appendItem(stored, true);
                }
                ToolTip.visible: hovered
                ToolTip.text: qsTr("store current measurement")
            }
        }
    }//ColumnLayout
}
