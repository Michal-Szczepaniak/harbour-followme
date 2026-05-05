import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

Page {
    id: providerPage
    allowedOrientations: Orientation.Portrait | Orientation.Landscape

    property var provider

    property var locator: [{id: provider, label: app.plugins[provider].label}]
    property int level: locator.length
    property var entryModel: []

    signal activate()
    signal done(bool success, var entries)

    SilicaListView {
        id: favList
        property bool loading: true

        anchors {
            top: parent.top
            bottom: queueProgress.top
        }
        width: parent.width

        function refreshSmartScrollbar() {

            try {
                _scrollbar = Qt.createQmlObject("
                    import QtQuick 2.0
                    import %1 1.0 as Private
        Private.Scrollbar {
                property int currentIndex: favList.indexAt(favList.contentX, favList.contentY) + 2
                        text: favList.currentSection
                        description: '%2'.arg(currentIndex).arg(favList.count)
                        headerHeight: root.headerItem ? root.headerItem.height : 0
        }".arg("Sailfish.Silica.private").arg("%1 / %2"), favList, 'Scrollbar')
            } catch (e) {
                if (!_scrollbar) {
                    console.warn(e)
                    console.warn('[BUG] failed to load customized scrollbar')
                    console.warn('[BUG] this probably means the private API has changed')
                }
            }
    }
    Component.onCompleted: refreshSmartScrollbar();
        header: Column {
            width: parent.width
            height: pageHeader.height + Theme.paddingLarge
            PageHeader {
                id: pageHeader
                title: app.plugins[provider].label + ' ' + app.plugins[provider].levels[level - 1].label
            }

            BusyIndicator {
                anchors.horizontalCenter: parent.horizontalCenter
                running: true
                size: BusyIndicatorSize.Large
                visible: favList.loading
            }

        }

        PullDownMenu {
            id: mainPullDownMenu
            MenuItem {
                text: qsTr("Refresh");
                onClicked: {
                    favList.loading = true;
                    favList.model = [];
                    entryModel = [];
                    favList.model = entryModel;
                    providerPage.activate();
                }
            }

        }

        model: entryModel

        delegate: FollowMeItem {
            // TODO: no loading, no last, no total, contextmenu
            id: followMeItem
            property var entryItem: entryModel[index]
            primaryText: entryItem.label != undefined ? entryItem.label : entryItem.id
            starred: (entryItem.want != undefined && entryItem.want)
            detail: false

            PyLoadEntry {
                base: app.dataPath
                locator: providerPage.locator.concat([{id:entryItem.id, label: entryItem.label, file: entryItem.file}]);
                autostart: true

                onFinished: {
                    if (success && entry != undefined) {
                        console.log('success in loading the item: ' + entry.id + ' from (old-id): ' + entryItem.id);
                        entryItem = entry;
                    }
                }
            }

            PySaveEntry {
                id: saveEntry
                base: app.dataPath
            }

            onClicked: {
                starred = !starred;
                entryItem.want = starred;
                console.log('toggle (+save) entryItem: ');
                console.log(JSON.stringify(entryItem));
                entryItem.locator = providerPage.locator.concat([{id:entryItem.id, label: entryItem.label, file: entryItem.file}]);
              //  entryItem.locator = [{id: entryItem.provider, label: entryItem.provider}, {id:entryItem.id, label: entryItem.label, file:entryItem.file}];
                console.log(JSON.stringify(entryItem));
                if (entryItem.items == undefined) {
                    entryItem.items = [];
                }
                console.log(JSON.stringify(entryItem))
                saveEntry.save(entryItem);
                if (entryItem.want) {
                    app.insertSort(entryItem);
                }
                else {
                    app.removedEntry(entryItem);
                }
            }
        }

      //      VerticalScrollDecorator {}
    }

    QueueProgress {
        id: queueProgress

        downloadQueue: app.downloadQueue

        anchors {
            bottom: parent.bottom
            bottomMargin: Theme.paddingSmall
            topMargin: Theme.paddingSmall
        }
        width: parent.width
    }

    onActivate: app.downloadQueue.immediate({
        locator: providerPage.locator,
        depth: 1,
        sort: true,
        needProvider: true,
        done: providerPage.done,
        doneHandler: function (success, item, entries, saveEntry){
            item.done(success, entries);
            return [];
        }
    }, function (){console.log('immediate request was filed; position: ' + app.downloadQueue.position);});

    onDone: {
        if (success) {
            console.log('found ' + entries.length + ' entries');
            entryModel = entries;
            favList.model = entryModel;
        }
        favList.loading = false;
    }

    Component.onCompleted: {
         activate();

    }
}

