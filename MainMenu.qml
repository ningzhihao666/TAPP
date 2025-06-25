import QtQuick
import QtQuick.Controls

//开始游戏菜单页面

Rectangle {
    color: "#f0f0f0"

    Image{
        source:"qrc:/BackGround/Images/BackGround/元气之战.jpg"
        anchors.fill:parent
    }

    Column {
        anchors.centerIn: parent
        spacing: 20

        Text {
            text: "元气之战：跑酷地牢(联机版)"
            font.pixelSize: 36
            color:"black"
            font.family: "Arial"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Button {
            background: Rectangle{ color:"lightgreen";  radius:5}
            text: "开始游戏"
            onClicked: stackView.push("Page_begin.qml")
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Button {
            background: Rectangle{ color:"lightgreen";   radius:5}
            text: "设置"
            onClicked: stackView.push("Settings.qml")
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Button {
            background: Rectangle{ color:"lightgreen";   radius:5}
            text: "退出"
            onClicked: Qt.quit()
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
