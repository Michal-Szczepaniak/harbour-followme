import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

CoverBackground {
	property string primaryText
	property string secondaryText
    property string chapterText

	Column {
		width: parent.width
        anchors.centerIn: parent

        Image {
            id: image

            source: "../images/harbour-followme.png"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Item {
            width: 1
            height: Theme.paddingLarge
        }

		Label {
			text: primaryText
			color: Theme.primaryColor
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
			truncationMode: TruncationMode.Fade
            width: parent.width - Theme.paddingLarge*2
            anchors.horizontalCenter: parent.horizontalCenter
		}

		Label {
			text: secondaryText
			color: Theme.secondaryColor
            horizontalAlignment: Text.AlignHCenter
			font.pixelSize: Theme.fontSizeSmall
			truncationMode: TruncationMode.Fade
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
		}

		Label {
			text: chapterText
			color: Theme.primaryColor
            horizontalAlignment: Text.AlignHCenter
			truncationMode: TruncationMode.Fade
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
		}

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

}

