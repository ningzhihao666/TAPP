import QtQuick 2.15
import QtQuick.Controls 2.15

//开始游戏菜单页面

Rectangle {
    color: "#f0f0f0"

    Image{
        source:"qrc:/page_begin/Images/page_begin/主页图.png"
        anchors.fill:parent
    }

    Column {
        anchors.centerIn: parent
        spacing: 20

        Text {
            text: "元气之战：跑酷地牢(联机版)"
            font.pixelSize: 36
            font.family: "Arial"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Button {
            background: Rectangle{ color:"white";  radius:5}
            text: "开始游戏"
            onClicked: stackView.push("Page_begin.qml")
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Button {
            background: Rectangle{ color:"white";   radius:5}
            text: "设置"
            onClicked: stackView.push("Boss_level.qml")
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Button {
            background: Rectangle{ color:"white";   radius:5}
            text: "退出"
            onClicked: Qt.quit()
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
