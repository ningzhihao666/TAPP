import QtQuick
import QtQuick.Controls
import QtQuick.Window

//游戏控制面板

Rectangle {
    property bool gameRunning: false
    property int distance:0

    property int  sc_x: Screen.width/200
    property int  sc_y: Screen.height/100

    width: parent.width
    height: Screen.height*0.18
    color: "transparent"

    property int score: 0

    signal pauseGame()

    //分数
    Rectangle{
        id:fenshu;     color:"transparent"
        height:Screen.height*0.1;      width:Screen.width/5
        radius:5;
        anchors{
            top:parent.top
            topMargin: Screen.height*0.02
            left:parent.left
            leftMargin: Screen.width*0.1
        }

        Image{
            id:img_1;    height:parent.height*0.8;   width:height;
            anchors{
                left:parent.left;    leftMargin: parent.width*0.05
                verticalCenter: parent.verticalCenter
            }
            source:"qrc:/BackGround/Images/BackGround/积分.png"
        }

        Label{
            height:parent.height*0.8;   width:parent.width*0.6
            text: "分数: " + score
            color: "blue"
            font.pixelSize: 20
            anchors{
                left:img_1.right;    leftMargin: parent.width*0.05
                verticalCenter: parent.verticalCenter
            }
        }
    }

    //距离
    Rectangle{
        id:juli;    color:"transparent"
        height:Screen.height*0.1;   width:Screen.width/5;   radius:5;
        anchors{
            top:parent.top
            topMargin: Screen.height*0.02
            horizontalCenter: parent.horizontalCenter
        }

        Image{
            id:img_2;    height:parent.height*0.8;   width:height;
            anchors{
                left:parent.left;    leftMargin: parent.width*0.05
                verticalCenter: parent.verticalCenter
            }
            source:"qrc:/BackGround/Images/BackGround/距离.png"
        }

        Label{
            height:parent.height*0.8;   width:parent.width*0.6
            text: "距离: " + distance/16
            color: "blue"
            font.pixelSize: 20
            anchors{
                left:img_2.right;    leftMargin: parent.width*0.05
                verticalCenter: parent.verticalCenter
            }
        }
    }

    //控制
    Rectangle{
        id:kongzhi;     color:"transparent"
        height:Screen.height*0.1;    width:Screen.width*0.15;   radius:5;
        anchors{
            top:parent.top
            topMargin: Screen.height*0.02
            right: parent.right
            rightMargin: Screen.width*0.05
        }

        Image{
            id:img_3;    height:parent.height;   width:height;
            anchors.centerIn: parent
            source:"qrc:/BackGround/Images/BackGround/暂停.png"

            Button {
                background: Rectangle{color:"transparent"}
                anchors.fill:parent
                onClicked: {
                    if (gameRunning) {
                        pauseGame()
                    }
                }
            }

        }
    }
}
