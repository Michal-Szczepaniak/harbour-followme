import QtQuick 2.2
import Sailfish.Silica 1.0
import "../components"

Page {
    id: entryPage

    // this is set from the MainPage, it has a locator, items
    property var parentEntry
    property bool horizon
    property bool showoverlay

    property var chapterLocator: parentEntry.locator.concat([{id: parentEntry.items[parentEntry.currentIndex].id, file: parentEntry.items[parentEntry.currentIndex].file, label: parentEntry.items[parentEntry.currentIndex].label}])
    property var chapter

    property int prev: parentEntry.currentIndex < 0 ? -1 : parentEntry.currentIndex - 1
    property int next: (parentEntry.currentIndex + 1) < parentEntry.items.length ? parentEntry.currentIndex + 1 : -1
    property var partModel: chapter !== undefined && chapter.items !== undefined ? chapter.items : ([])

    signal gotoSibling (int number)
    signal showChapter (bool success, var item)
    signal chapterLoaded ()
    signal markRead (bool force)
    signal markLast ()
    signal calcCurrentCompletion ()

    allowedOrientations: Orientation.All //Portrait | Orientation.Landscape

onOrientationChanged: {
         entryView.interactive = true;
    }
SilicaFlickable {
        id: picFlick
        contentWidth: width
        contentHeight: height
        anchors.fill: parent
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
            visible: prev >= 0 || next > 0
            MenuItem {
                visible: parentEntry.items.length > 1
                text: qsTr("Jump To")
                onClicked: {
                    var dialog = pageStack.push(Qt.resolvedUrl("SliderDialog.qml"), {
                        title: qsTr("Jump to chapter"),
                        number: entryPage.parentEntry.currentIndex + 1,
                        unit: qsTr("chapter"),
                        minimum: 1,
                        maximum: entryPage.parentEntry.items.length
                    });
                    dialog.accepted.connect(function (){
                        gotoSibling(dialog.number - 1);
                    });
                }
            }
            MenuItem {
                visible: true
                text: qsTr("Back")
                onClicked: pageStack.pop();
            }
            MenuItem {
                visible: next > 0
                text: qsTr("Next")
                onClicked: gotoSibling(next);
            }
            MenuItem {
                visible: prev >= 0
                text: qsTr("Previous")
                onClicked: gotoSibling(prev);
            }
        }

        PushUpMenu {
            visible: next > 0
            MenuItem {
                text: qsTr("Next")
                onClicked: gotoSibling(next);
            }
        }



        SilicaGridView {
        id: entryView
        anchors.fill: parent
            cellWidth:  parent.width
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

        model: partModel
//onCurrentIndexChanged: picFlick._fit()
        delegate: FollowMeImageH {
            id: followMeImage

            property var part: partModel[index]

            width: picFlick.contentWidth
            height: picFlick.contentHeight
            smooth: !(picFlick.movingVertically || picFlick.movingHorizontally)
            parentLocator: chapter.locator
            partIndex: index
            partId: part.id
            file: part.file
            absoluteFile: part.absoluteFile != undefined ? app.dataPath + part.absoluteFile : ''

            signal refreshImage()
            signal refreshImageFilename()
            signal imageSaved(bool success, var entry)

            onRefreshImageFilename: {
                console.log("refreshing image filename...");
                app.downloadQueue.immediate({
                    locator: parentLocator.concat([{id: part.id, file: part.file, label: part.label}]),
                    entry: entryPage.chapter,
                    pageIndex: partIndex,
                    saveHandler: imageSaved
                });
            }

            onRefreshImage: {
                console.log("refreshing image (ie: re-download " + entryPage.chapter.items[partIndex]['remoteFile'] + ")...");
                app.downloadQueue.immediate({
                    locator: parentLocator.concat([{id: part.id, file: part.file, label: part.label},{}]),
                    chapter: entryPage.chapter,
                    remoteFile: entryPage.chapter.items[partIndex]['remoteFile'],
                    pageIndex: partIndex,
                    saveHandler: imageSaved
                }, function (){
                    //console.log('immediate download has been queued, clearing the imageSource', followMeImage.imageSource);
                    //followMeImage.imageSource = '';
                });
            }

            onImageSaved: {
                if (success && entryPage.chapter.items[followMeImage.partIndex].absoluteFile != undefined && entryPage.chapter.items[followMeImage.partIndex].absoluteFile != '') {
                    console.log("image was saved properly, now it's time to set the imageSource");
                    followMeImage.imageSource = app.dataPath + entryPage.chapter.items[followMeImage.partIndex].absoluteFile;
                    console.log(followMeImage.imageSource );
                }
            }

            onImageError: {
            //	console.log("image has error, redownloading it...");
                if (entryPage.chapter.items[partIndex]['remoteFile'] != undefined) {
                    refreshImage();
                }
                else {
                    refreshImageFilename();
                }
            }

        }
        }


}
    PySaveEntry {
        id: saveChapter
        base: app.dataPath
        entry: entryPage.chapter

        onFinished: {
            console.log('saving chapter: ' + (success ? "ok" : "nok"));
        }
    }

    PySaveEntry {
        id: saveEntry
        base: app.dataPath
        entry: entryPage.parentEntry

        onFinished: {
            console.log('saving entry: ' + (success ? "ok" : "nok"));
        }
    }

    PyLoadEntry {
        id: loadChapter
        base: app.dataPath
        locator: chapterLocator
        autostart: true

        onFinished: {
            if (success) {
                console.log("loading chapter finished: " + entry.label);
                // fix label before saving parent
                if (entry.label != undefined) {
                    parentEntry.items[parentEntry.currentIndex].label = entry.label;
                }
                chapter = entry;
                chapterLoaded();
                return ;
            }
            // fetch them online (not from dir)
            console.log('downloading chapter');
            // show busyIndicator by destroying the chapter items
            entryView.model = [];
            // make a chapter start (either it's gotten corrupted, or it's a new one)
            // either way, create a new basic chapter to start with
            chapter = ({id: parentEntry.items[parentEntry.currentIndex].id, file: parentEntry.items[parentEntry.currentIndex].file, label: parentEntry.items[parentEntry.currentIndex].label, items: [], read: false, locator: chapterLocator});
            partModel = chapter.items;
            entryView.model = partModel;
            // TODO: when it's done, i need to do the same stuff if it were successfull in loading...
            app.downloadQueue.immediate({
                locator: chapter.locator,
                depth: 1,
                sort: true,
                entry: chapter,
                signal: showChapter
            });
        }
    }

    onShowChapter: {
        console.log('chapter now has ' + chapter.items.length + ' parts, setting model (maybe reset is required first?)');
        partModel = chapter.items;
        //entryView.model = partModel;
        if (success) {
            chapterLoaded();
        }
    }

    onChapterLoaded: {
        console.log("chapter index " + entryPage.parentEntry.currentIndex + " has loaded: " + chapter.label);
        partModel = chapter.items;
        markLast();
        entryView.model = partModel;
        if (parentEntry.currentPage != undefined) {
console.log(parentEntry.currentPage)
            for(var i = 0;i<parentEntry.currentPage; i++){
                entryView.moveCurrentIndexRight();
            }
        //	entryView.positionViewAtIndex(parentEntry.currentPage, GridView.Visible);

        }

        // mark it as read
        console.log("saving to chapter: " + entryPage.parentEntry.currentIndex);
        markRead(false);

        // fix the cover
        app.coverPage.primaryText = parentEntry.label;
        app.coverPage.secondaryText = parentEntry.locator[0].label;
        app.coverPage.chapterText = 'Chapter: ' + (parentEntry.items[parentEntry.currentIndex].label != undefined ? parentEntry.items[parentEntry.currentIndex].label : parentEntry.items[parentEntry.currentIndex].id);
    }

    onMarkRead: {
        // no need to save if already read
        if (chapter.read != undefined && chapter.read && !force) {
            return ;
        }
        // mark chapter read
        chapter.read = true;
        saveChapter.activate();
    }

    onMarkLast: {
        // no need to save parentEntry if this was the last one
        if (parentEntry.last != undefined && parentEntry.last == parentEntry.items[parentEntry.currentIndex].id) {
            return ;
        }
        // save last entry
        parentEntry.last = parentEntry.items[parentEntry.currentIndex].id;
        saveEntry.activate();
        console.log('trying to signal entry update in main: ' + parentEntry.last);
        app.entryUpdate(parentEntry.locator[0].id + '/' + parentEntry.locator[1].id);
    }

    onCalcCurrentCompletion: {
        if (parentEntry.items.length > 0) {
        /*	if (entryView.count <= 1 || entryView.indexAt(0, entryView.contentY + entryView.height) == entryView.count - 1) {
                if (parentEntry.items.length > 0) {
                    parentEntry.currentPage = parentEntry.items[parentEntry.items.length - 1].id;
                }
                parentEntry.currentCompletion = 1;
                saveEntry.activate();
            }
            else {*/
                var currentPartIndex = entryView.indexAt(entryView.contentX, 0);

                if (currentPartIndex != undefined && parentEntry.items[currentPartIndex] != undefined && parentEntry.items.length != 0) {
                    parentEntry.currentPage = entryView.currentIndex//  entryView.indexAt(entryView.contentX, 0);//parentEntry.items[currentPartIndex].id;

                    parentEntry.currentCompletion = parentEntry.currentPage / parentEntry.items.length;

                    var currentPartIndex = entryView.indexAt(entryView.contentX, 0);

                    saveEntry.activate();
                }
            }
    //	}
    }

    onGotoSibling: {
        console.log('gotoSibling(' + number + '): ' + parentEntry.items[number].id);
        entryView.model = [];
        parentEntry.currentIndex = number;
        parentEntry.currentPage = undefined;
        parentEntry.currentCompletion = undefined;
        prev = (parentEntry.currentIndex < 0 ? -1 : parentEntry.currentIndex - 1);
        next = ((parentEntry.currentIndex + 1) < parentEntry.items.length ? parentEntry.currentIndex + 1 : -1);
        console.log('gotoSibling(' + parentEntry.currentIndex + '): current: ' + parentEntry.items[parentEntry.currentIndex].id);
        chapterLocator = parentEntry.locator.concat([{id: parentEntry.items[parentEntry.currentIndex].id, file: parentEntry.items[parentEntry.currentIndex].file, label: parentEntry.items[parentEntry.currentIndex].label}]);
        console.log('gotoSibling(' + parentEntry.currentIndex + '): chapterLocator: ' + chapterLocator[chapterLocator.length - 1].id);
        entryView.model = partModel;
        loadChapter.activate();
    }

    onStatusChanged: {
        if (status == PageStatus.Deactivating) {
            // when going back, store the currentCompletion
            calcCurrentCompletion();
            app.moveSort(parentEntry, -1);
        }
    }

}
