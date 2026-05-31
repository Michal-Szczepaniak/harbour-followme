import QtQuick 2.0
import Sailfish.Silica 1.0

GridItem {
    id: listItem

    property int partIndex
    property string partId
    property string file
    property string absoluteFile
    property var parentLocator

    signal imageError (var parentLocator, int partIndex, string partId)

    property alias imageSource: imageFile.source
    property bool ready: imageFile.status === Image.Ready

    Image {
        id: imageFile
        source: absoluteFile
        fillMode: Image.PreserveAspectFit
        anchors.fill: parent

        Component.onCompleted: {
            if (imageFile.status === Image.Error || absoluteFile == '') {
                console.log("error in image " + absoluteFile);
                imageError(listItem.parentLocator, listItem.partIndex, listItem.partId);
            }

        }

        Label {
            id: chapterno
            visible: showoverlay && horizon
            anchors.fill: parent
            color: Theme.highlightColor
            opacity: 0.9
            style: Text.Outline
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            text: parentEntry.label + ": " + qsTr("Chapter") + " " + (chapter != undefined && chapter.label != undefined ? chapter.label + ' (' +( partIndex+1) + '/' + (partModel.length ) + ')' : ( parentEntry.items[parentEntry.currentIndex].label != undefined ? parentEntry.items[parentEntry.currentIndex].label  : parentEntry.items[parentEntry.currentIndex].id ) )

        }
    }

    BusyIndicator {
        id: busyFile
        running: true
        size: BusyIndicatorSize.Medium
        visible: !ready
        anchors.centerIn: parent
    }
}

