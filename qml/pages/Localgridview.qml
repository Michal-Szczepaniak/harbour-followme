import QtQuick 2.0
import io.thp.pyotherside 1.4
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0

Page {
    property int img
    property var filepath
    property bool showoverlay
    property int total
    property int bookmrk
    property int curindex
    property var comconf: filepath.replace(/\./g, "").replace(/\//g, "")
    allowedOrientations: Orientation.All

    ConfigurationGroup {
        id: mainConfig
        path: "/apps/harbour-followme"
    }

    ConfigurationValue {
        id: bookmark
        key: "/apps/harbour-followme/" + comconf
    }

    onStatusChanged: {
        if (status == PageStatus.Deactivating) {
            mainConfig.setValue(comconf, entryView.currentIndex);
        }
    }
    SilicaFlickable{
        id: picFlick
        anchors.fill: parent
        contentWidth: width
        contentHeight: height
        pressDelay: 0
        function _fit() {
            fitAnimation.start()
        }
        // Animation for zooming out
        ParallelAnimation {
            id: fitAnimation
            running: false

            NumberAnimation { target: picFlick; property: "contentWidth"; to: width; duration: 100 }
            NumberAnimation { target: picFlick; property: "contentHeight"; to: height; duration: 100 }
            NumberAnimation { target: picFlick; property: "contentX"; to: 0; duration: 100 }
            NumberAnimation { target: picFlick; property: "contentY"; to: 0; duration: 100 }
        }
        PullDownMenu {

            MenuItem {

                text: qsTr("Jump To")
                onClicked: {
                    var dialog = pageStack.push(Qt.resolvedUrl("SliderDialog.qml"), {
                                                    title: qsTr("Jump to page"),
                                                    number: entryView.currentIndex + 1,
                                                    unit: qsTr("page"),
                                                    minimum: 1,
                                                    maximum: commodel.count
                                                });
                    dialog.accepted.connect(function (){
                        var numstart = entryView.currentIndex + 1
                        if(dialog.number > numstart){
                            for(var i = 0;i< (dialog.number - numstart); i++){
                                entryView.moveCurrentIndexRight();
                            }
                        } else {
                            for(var i = 0;i< (numstart - dialog.number); i++){
                                entryView.moveCurrentIndexLeft();
                            }
                        }
                    });
                }
            }
            MenuItem {
                visible: true
                text: qsTr("Back")
                onClicked: pageStack.pop();
            }
        }
        ListModel { id: commodel }
        SilicaGridView {
            id: entryView
            //      cacheBuffer: 0// parent.width*3
            anchors.fill: parent
            cellWidth: parent.width
            cellHeight: parent.height
            snapMode: GridView.SnapOneRow
            flow: GridView.FlowTopToBottom
            flickableDirection: Flickable.HorizontalAndVerticalFlick
            highlightRangeMode: GridView.StrictlyEnforceRange

            PinchArea {
                width: Math.max(picFlick.contentWidth, picFlick.width)
                height: Math.max(picFlick.contentHeight, picFlick.height)
                property real initialWidth
                property real initialHeight

                onPinchStarted: {
                    initialWidth = picFlick.contentWidth
                    initialHeight = picFlick.contentHeight
                }

                onPinchUpdated: {
                    picFlick.contentX += pinch.previousCenter.x - pinch.center.x
                    picFlick.contentY += pinch.previousCenter.y - pinch.center.y

                    var newWidth = Math.max(initialWidth * pinch.scale, picFlick.width)
                    var newHeight = Math.max(initialHeight * pinch.scale, picFlick.height)

                    newWidth = Math.min(newWidth, picFlick.width * 3)
                    newHeight = Math.min(newHeight, picFlick.height * 3)

                    picFlick.resizeContent(newWidth, newHeight, pinch.center)
                    if(picFlick.contentWidth > picFlick.width || picFlick.contentHeight > picFlick.height){
                        entryView.interactive = false
                    } else {
                        entryView.interactive = true
                    }
                }

                onPinchFinished: {
                    picFlick.returnToBounds()
                }

                // Doubletap to zoom and doubletap to return to images
                MouseArea {
                    id: doubleTapArea
                    width: Math.max(picFlick.contentWidth, picFlick.width)
                    height: Math.max(picFlick.contentHeight, picFlick.height)
                    onPressAndHold: showoverlay = !showoverlay
                    onDoubleClicked: function() {
                        if (picFlick.contentWidth <= picFlick.width) {
                            entryView.interactive = false
                            picFlick.resizeContent(picFlick.width * 2.5, picFlick.height * 2.5, Qt.point(doubleTapArea.mouseX, doubleTapArea.mouseY))

                            picFlick.returnToBounds()
                        }
                        else {
                            entryView.interactive = true
                            picFlick._fit()
                        }
                    }
                }
            }
            model: commodel
            onCurrentIndexChanged: curindex = currentIndex


            delegate:    GridItem{
                id: gitem

                Image {
                    id: image
                    asynchronous: true
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit

                    Python {
                        id: py2
                        Component.onCompleted: {

                            addImportPath(Qt.resolvedUrl('../python/'));
                            importModule('imageprovider', function () {
                                image.source = 'image://python/' + filepath + '+' +   index//test
                            });
                        }
                        onError: console.log('Python error: ' + traceback)
                    }

                    Label {
                        id: chapterno
                        visible: showoverlay
                        anchors.fill: parent
                        color: Theme.highlightColor
                        opacity: 0.9
                        style: Text.Outline
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        text:  index + 1 + "/" + commodel.count

                    }
                }
            }
        }


        Python {
            id: py
            Component.onCompleted: {

                addImportPath(Qt.resolvedUrl('../python/'));
                importModule('parse', function() {
                    call('parse.parse', [ filepath ], function () {});
                });
                setHandler('comcount', function(result) {
                    if (total === 'undefined' || total == 0) {
                        total = result.length
                        for (var i = 0; i < total; i++) commodel.append({'test':i})
                    }
                    //   console.log(commodel.count, comconf)
                    bookmrk = mainConfig.value(comconf, 0);
                    for(var i = 0;i<=bookmrk; i++){
                        entryView.moveCurrentIndexRight();
                    }
                });
            }
            onError: console.log('Python error: ' + traceback)

        }
    }
}
