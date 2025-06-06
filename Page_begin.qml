import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtMultimedia
import Qt.labs.settings

//游戏进入开始页面

Page{
    id:page_begin

    property int  sc_x: Screen.width/200                        //屏幕横向划分为200份
    property int  sc_y: Screen.height/100                       //屏幕纵向划分为100份（因为手机横屏）

    property int  current_Score:0                               //当前得分
    property int  current_Distance:0                            //当前距离

    //本地存储数据
    property string historyScores:"0,0,0"                       //历史前三得分
    property string historyDistance:"0,0,0"                     //历史前三距离
    property int coin_num:0                                     //金币数量
    property int masonry_num:0                                  //砖石数量

    // 转换为数组的只读属性
    property var history_Scores: historyScores.split(',').map(Number)
    property var history_Distances: historyDistance.split(',').map(Number)


    //设置存储
    Settings{
        id:gameSettings
        category:"GameRecords"

        property alias historyScores:page_begin.historyScores
        property alias historyDistance:page_begin.historyDistance
    }

    //初始化历史记录
    Component.onCompleted: {
        if(current_Distance){
            saveRecord(current_Score,current_Distance)
        }
    }

    //保存新记录
    function saveRecord(score,distance){
        //转化字符串为数组
        var scoreArray=historyScores.split(',').map(Number)
        var distanceArray=historyDistance.split(',').map(Number)

        //更新记录
        scoreArray.push(score)
        distanceArray.push(distance)

        //排序保留前三
        scoreArray.sort((a,b)=>b-a)
        distanceArray.sort((a,b)=>b-a)

        //更新字符串属性
        historyScores=scoreArray.slice(0,3).join(',')
        historyDistance=distanceArray.slice(0,3).join(',')

        gameSettings.sync()
    }

    Image{
        source:"qrc:/BackGround/Images/BackGround/背景2.jpg"
        anchors.fill:parent
    }

    MediaPlayer {
        audioOutput: AudioOutput { volume:1 }
        source: "qrc:/musics/musics/跳楼机.mp3"
        loops:MediaPlayer.Infinite
        Component.onCompleted: { play() }
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

        Rectangle{
            id:rec_1;
            height:parent.height/5;    width:parent.width*0.9;   color:"transparent"
            anchors{
                top:parent.top;    topMargin: sc_y*28
                horizontalCenter: parent.horizontalCenter
            }
            Rectangle{
                height:parent.height;  width:parent.width/3;   color:"transparent"
                anchors{horizontalCenter: parent.horizontalCenter; top:parent.top}
                Label{text:history_Scores[0]; anchors.centerIn: parent; color:"black"}
            }
            Rectangle{
                height:parent.height;  width:parent.width/3;   color:"transparent"
                anchors{right: parent.right; top:parent.top}
                Label{text:history_Distances[0]; anchors.centerIn: parent; color:"black"}
            }
        }
        Rectangle{
            id:rec_2;
            height:parent.height/5;    width:parent.width*0.9;   color:"transparent"
            anchors{
                top:rec_1.bottom;    topMargin: sc_y*3
                horizontalCenter: parent.horizontalCenter
            }
            Rectangle{
                height:parent.height;  width:parent.width/3;   color:"transparent"
                anchors{horizontalCenter: parent.horizontalCenter; top:parent.top}
                Label{text:history_Scores[1]; anchors.centerIn: parent; color:"black"}
            }
            Rectangle{
                height:parent.height;  width:parent.width/3;   color:"transparent"
                anchors{right: parent.right; top:parent.top}
                Label{text:history_Distances[1]; anchors.centerIn: parent; color:"black"}
            }
        }
        Rectangle{
            id:rec_3;
            height:parent.height/5;    width:parent.width*0.9;   color:"transparent"
            anchors{
                top:rec_2.bottom;    topMargin: sc_y*3
                horizontalCenter: parent.horizontalCenter
            }
            Rectangle{
                height:parent.height;  width:parent.width/3;  color:"transparent"
                anchors{horizontalCenter: parent.horizontalCenter; top:parent.top}
                Label{text:history_Scores[2]; anchors.centerIn: parent; color:"black"}
            }
            Rectangle{
                height:parent.height;  width:parent.width/3;  color:"transparent"
                anchors{right: parent.right; top:parent.top}
                Label{text:history_Distances[2]; anchors.centerIn: parent; color:"black"}
            }
        }
    }

    //金币容器
    Rectangle{
        id:coin_list
        height:Screen.height*0.05;    width:Screen.width*0.13
        border.width:1;     color:"lightblue"
        radius:Screen.height*0.02
        anchors{
            left:mianban.right;  leftMargin: parent.width*0.05
            top:parent.top;      topMargin:parent.height*0.05
        }

        Image{
            id:coin_l
            height:parent.height*0.8;  width:height
            anchors{
                left:parent.left;  leftMargin:parent.width*0.05
                verticalCenter: parent.verticalCenter
            }
            source:"qrc:/BackGround/Images/BackGround/金币.png"
        }

        Rectangle{
            width:parent.width*0.6; height:parent.height*0.8; border.width:1
            anchors{
                left:coin_l.right;  leftMargin: parent.width*0.04
                verticalCenter: parent.verticalCenter
            }
            Label{text:coin_num;  color:"black";  anchors.centerIn:parent  }
        }
    }

    //砖石容器
    Rectangle{
        height:Screen.height*0.05;    width:Screen.width*0.13
        border.width:1;     color:"lightblue"
        radius:Screen.height*0.02
        anchors{
            left:coin_list.right;  leftMargin: parent.width*0.05
            top:parent.top;      topMargin:parent.height*0.05
        }

        Image{
            id:zhuanshi_l
            height:parent.height*0.8;  width:height
            anchors{
                left:parent.left;  leftMargin:parent.width*0.05
                verticalCenter: parent.verticalCenter
            }
            source:"qrc:/BackGround/Images/BackGround/砖石.png"
        }

        Rectangle{
            width:parent.width*0.6; height:parent.height*0.8; border.width:1
            anchors{
                left:zhuanshi_l.right;  leftMargin: parent.width*0.04
                verticalCenter: parent.verticalCenter
            }
            Label{text:coin_num;  color:"black";  anchors.centerIn:parent  }
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
            width:parent.width*0.8
            anchors.centerIn: parent
            background: Rectangle{color:"yellow"; border.width:1; radius:5}
            Label{text:"开始游戏"; color:"black"; anchors.centerIn: parent}
            onClicked: {
                stackView.replace("GameScreen.qml",{
                                  "gameRunning":true
                                  })
            }
        }
    }
}
