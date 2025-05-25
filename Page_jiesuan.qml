import QtQuick
import QtQuick.Controls
import QtQuick.Window

//死亡结算页面

Page{
    id:page_jiesuan
    property int distance:0                //总距离
    property int score:0                   //总得分
    property int history_maxScore:0        //历史最高分
    property int coins_num:0               //金币数量

    enabled: true

    Image{
        source:"qrc:/BackGround/Images/BackGround/结算背景.jpg"
        anchors.fill:parent
    }

    //得分面板
    Rectangle{
        id:mianban
        height:Screen.height*0.8
        width:Screen.width*0.3
        radius:10

        border.width:1
        anchors{
            verticalCenter: parent.verticalCenter
            left:parent.left
            leftMargin:Screen.width*0.2
        }

        Image{
            source:"qrc:/BackGround/Images/BackGround/结算面板.png"
            anchors.fill:parent
        }

        //历史最高分
        Rectangle{
            height:parent.height*0.1
            width:parent.width*0.5
            color:"transparent"
            anchors{
                left:parent.left
                leftMargin: parent.width*0.4
                top:parent.top
                topMargin: parent.height*0.15
            }
            Label{
                text:history_maxScore
                color:"black"
            }
        }

        //得分
        Rectangle{
            height:parent.height*0.1
            width:parent.width*0.6
            //border.width:1
            anchors{
                top:parent.top
                topMargin: parent.height*0.37
                horizontalCenter: parent.horizontalCenter
            }
            Label{
                text:score
                color:"black"
                anchors.centerIn: parent
            }
        }

        //距离
        Rectangle{
            height:parent.height*0.1
            width:parent.width*0.5
            color:"transparent"
            anchors{
                left:parent.left
                leftMargin: parent.width*0.45
                top:parent.top
                topMargin: parent.height*0.63
            }
            Label{
                text:distance
                color:"black"
            }
        }

        //金币数量
        Rectangle{
            height:parent.height*0.1
            width:parent.width*0.5
            color:"transparent"
            anchors{
                left:parent.left
                leftMargin: parent.width*0.45
                top:parent.top
                topMargin: parent.height*0.74
            }
            Label{
                text:coins_num
                color:"black"
            }
        }
    }

    //角色展示和返回按钮
    Rectangle{
        id:juese
        height:Screen.height*0.6
        width:Screen.width*0.3
        radius:10
        color:"transparent"

        anchors{
            top:mianban.top
            left:mianban.right
        }

        Image{
            source:"qrc:/player/Images/player/页面图.png"
            anchors.fill:parent
        }
    }

    Rectangle{
        id:fanhui
        height:Screen.height*0.2
        width:Screen.width*0.3
        radius:10
        color:"transparent"

        anchors{
            top:juese.bottom
            left:mianban.right
        }

        Button{
            height:parent.height*0.8
            width:parent.width*0.5
            anchors.centerIn: parent
            background: Rectangle{color:"yellow"; border.width:1; radius:5}
            Label{text:"重新开始"; color:"black"; anchors.centerIn: parent}
            onClicked: {
                console.log("按钮被点击")
                stackView.replace("Page_begin.qml",{
                                  "current_Score":score,
                                  "current_Distance":distance
                                  })
            }
        }
    }
}
