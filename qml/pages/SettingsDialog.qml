import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0

Dialog {
    allowedOrientations: Orientation.Portrait | Orientation.Landscape

    property alias dataPath: dataPathField.text
    property bool checkemb: horizontal.value
    property bool checkemc: sizecalc.value

    ConfigurationGroup {
        id: mainConfig
        path: "/apps/harbour-followme"
    }
    ConfigurationValue {
        id: horizontal
        key: "/apps/harbour-followme/horizontal"
    }
    ConfigurationValue {
        id: sizecalc
        key: "/apps/harbour-followme/sizecalc"
    }
    Column {
        width: parent.width

        PageHeader {
            id: pageHeader
            title: qsTr("FollowMe settings")
        }

        Label {
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            width: parent.width
            text: qsTr("This data path will be used to store the images as well as the tracking data of all the followed entries. Keep in mind that if you change the data path after using the application, you will have to move the data manually.")
            anchors {
                left: parent.left
                right: parent.right
                leftMargin: Theme.horizontalPageMargin
                rightMargin: Theme.horizontalPageMargin
            }
        }

        Item {
            width: 1
            height: Theme.paddingLarge
        }

        TextField {
            id: dataPathField
            width: parent.width
            label: qsTr("Data path")
            anchors {
                left: parent.left
                right: parent.right
                leftMargin: Theme.horizontalPageMargin
                rightMargin: Theme.horizontalPageMargin
            }
        }

        TextSwitch{
            id: horiz
            text: qsTr("Horizontal viewing")
            checked: checkemb
            onCheckedChanged: {

                mainConfig.setValue("horizontal", checked);

            }
        }
        TextSwitch{
            id: sizeautocalc
            text: qsTr("Calculate download size")
            checked: checkemc
            onCheckedChanged: {

                mainConfig.setValue("sizecalc", checked);

            }
        }

    }
}
