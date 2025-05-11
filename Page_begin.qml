import QtQuick
import QtQuick.Controls
import QtQuick.Window

//游戏进入开始页面

Page{
    id:page_begin
    Image{
        source:"qrc:/BackGround/Images/BackGround/背景2.jpg"
        anchors.fill:parent
    }

    //历史得分榜
    Rectangle{
        id:mianban
        height:Screen.height*0.85
        width:Screen.width*0.45
        radius:10
        color:"transparent"

        anchors{
            top:parent.top
            topMargin: parent.height*0.1
            left:parent.left
            leftMargin:Screen.width*0.1
        }

        Image{
            source:"qrc:/BackGround/Images/BackGround/历史排行榜.png"
            anchors.fill:parent
        }
    }

    //角色展示
    Rectangle{
        id:juese
        height:Screen.height*0.6
        width:Screen.width*0.3
        radius:10
        color:"transparent"

        anchors{
            top:mianban.top
            left:mianban.right
            leftMargin: parent.width*0.05
        }

        Image{
            source:"qrc:/player/Images/player/页面图.png"
            anchors.fill:parent
        }
    }

    //开始按钮
    Rectangle{
        id:fanhui
        height:Screen.height*0.2
        width:Screen.width*0.3
        radius:10
        color:"transparent"

        anchors{
            top:juese.bottom
            topMargin: parent.height*0.05
            left:mianban.right
            leftMargin: parent.width*0.05
        }

        Button{
            height:parent.height*0.8
            width:parent.width*0.5
            anchors.centerIn: parent
            background: Rectangle{color:"yellow"; border.width:1; radius:5}
            Label{text:"开始游戏"; color:"black"; anchors.centerIn: parent}
            onClicked: {
                stackView.replace("GameScreen.qml")
            }
        }
    }
}
