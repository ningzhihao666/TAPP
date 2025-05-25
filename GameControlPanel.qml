import QtQuick
import QtQuick.Controls
import QtQuick.Window

Rectangle {
    property bool gameRunning: false
    property int distance:0

    property int  sc_x: Screen.width/200
    property int  sc_y: Screen.height/100

    width: parent.width
    height: 60
    color: "#80000000" // 半透明黑色

    property int score: 0

    signal startGame()
    signal pauseGame()

    //分数
    Rectangle{
        id:fenshu
        height:Screen.height*0.1
        width:Screen.width/5
        radius:5;        border.width:1
        anchors{
            top:parent.top
            topMargin: Screen.height*0.02
            left:parent.left
            leftMargin: Screen.width*0.1
        }
        Label{
            text: "分数: " + score
            color: "blue"
            font.pixelSize: 20
            anchors.fill:parent
        }
    }

    //距离
    Rectangle{
        id:juli
        height:Screen.height*0.1
        width:Screen.width/5
        radius:5;        border.width:1
        anchors{
            top:parent.top
            topMargin: Screen.height*0.02
            horizontalCenter: parent.horizontalCenter
        }
        Label{
            text: "距离: " + distance/16
            color: "blue"
            font.pixelSize: 20
            anchors.fill:parent
        }
    }

    //控制
    Rectangle{
        id:kongzhi
        height:Screen.height*0.1
        width:Screen.width/5
        radius:5;        border.width:1
        anchors{
            top:parent.top
            topMargin: Screen.height*0.02
            right: parent.right
            rightMargin: Screen.width*0.05
        }

        Button {
            text: gameRunning ? "暂停" : "开始"
            anchors.fill:parent
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
