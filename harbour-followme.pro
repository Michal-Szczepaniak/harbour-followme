# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-followme


CONFIG += sailfishapp_qml

DIST_FILES += qml/harbour-followme.qml \
    translations/*.ts \
    harbour-followme.png \
    harbour-followme.desktop \
    qml/resources/css/followme.css \
    qml/resources/js/followme.js \
    qml/components/Ajax.qml \
    qml/components/DownloadQueue.qml \
    qml/components/Fetch.qml \
    qml/components/FollowMeImage.qml \
    qml/components/FollowMeItem.qml \
    qml/components/PyCleanEntry.qml \
    qml/components/PyCreateDataPath.qml \
    qml/components/PyDataPath.qml \
    qml/components/PyDownloadFile.qml \
    qml/components/PyListEntries.qml \
    qml/components/PyLoadEntry.qml \
    qml/components/PySaveEntry.qml \
    qml/components/PySizeEntry.qml \
    qml/components/QueueProgress.qml \
    qml/cover/CoverPage.qml \
    qml/pages/AddEntryPage.qml \
    qml/pages/EntryPage.qml \
    qml/pages/ListPage.qml \
    qml/pages/MainPage.qml \
    qml/pages/ProviderPage.qml \
    qml/pages/SearchDialog.qml \
    qml/pages/SearchPage.qml \
    qml/pages/SettingsDialog.qml \
    qml/pages/SliderDialog.qml \
    qml/python/followme.py \
    qml/images/starGold.svg \
    qml/images/starGrey.svg \
    qml/scripts/download.js \
    qml/plugins/MangaTown/.FollowMe \
    harbour-followme.svg \
    rpm/harbour-followme.spec

CONFIG += sailfishapp_i18n

TRANSLATIONS += \
    translations/harbour-followme-de.ts \
    translations/harbour-followme-fi.ts \
    translations/harbour-followme-nl.ts \
    translations/harbour-followme-it.ts \
    translations/harbour-followme-es.ts \
    translations/harbour-followme-pl.ts \
    translations/harbour-followme-fr.ts

DISTFILES += \
    qml/components/FollowMeImageH.qml \
    qml/pages/Localgridview.qml \
    qml/plugins/MangaKatana/.FollowMe \
    qml/plugins/MangaTown/.FollowMe \
    qml/plugins/DynastyScans/.FollowMe \
    qml/python/imageprovider.py \
    qml/python/parse.py \
    qml/python/rarfile.py \
    rpm/harbour-followme.spec
