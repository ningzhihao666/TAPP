import QtQuick 2.15
import QtQuick.Controls 2.15

//开始游戏菜单页面

Rectangle {
    color: "#f0f0f0"

    Column {
        anchors.centerIn: parent
        spacing: 20

        Text {
            text: "天天跑酷"
            font.pixelSize: 36
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Button {
            text: "开始游戏"
            onClicked: stackView.push(gameScreen)
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Button {
            text: "设置"
            // 打开设置界面
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Button {
            text: "退出"
            onClicked: Qt.quit()
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
