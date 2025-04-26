import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    property bool gameRunning: false
    property int distance:0

    width: parent.width
    height: 60
    color: "#80000000" // 半透明黑色

    property int score: 0

    signal startGame()
    signal pauseGame()

    Row {
        anchors.fill: parent
        spacing: 10
        padding: 10

        Text {
            text: "分数: " + score
            color: "white"
            font.pixelSize: 20
            verticalAlignment: Text.AlignVCenter
            height: parent.height
        }

        Text {
            text: "距离: " + distance
            color: "white"
            font.pixelSize: 20
            verticalAlignment: Text.AlignVCenter
            height: parent.height
        }

        Button {
            text: gameRunning ? "暂停" : "开始"
            height: parent.height
            onClicked: {
                if (gameRunning) {
                    pauseGame()
                } else {
                    startGame()
                }
            }
        }
    }
}
