import QtQuick
import QtQuick.Controls
import QtQuick.Window

//人物角色页面

Item {
    id: player

    property var run_images:["qrc:/player/Images/player/跑动1.png",
                             "qrc:/player/Images/player/跑动2.png",
                             "qrc:/player/Images/player/跑动3.png",
                             "qrc:/player/Images/player/跑动4.png",
                             "qrc:/player/Images/player/跑动5.png",
    ]

    //"qrc:/player/Images/player/滑铲1.png",
    //"qrc:/player/Images/player/跳跃1.png",
    //"qrc:/player/Images/player/跳跃2.png",

    property int currentImage: 3
    property bool isJumping: false
    property bool isSliding: false
    property bool isDowning: false

    property bool gameRunning:false
    property bool zhengxiang:true              //正向
    property bool isSiding:false

    width: Screen.width/12
    height:Screen.height/6

    Image {
        id:play_img
        source: "qrc:/player/Images/player/跑动4.png"
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit

        //跑动,跳跃，滑铲图片转化
        Timer{
            interval:80
            repeat:true
            running:gameRunning
            onTriggered: {
                //console.log("当前高度为：",height)
                //console.log("当前宽度为:",width)
                //切换到下一帧
                if(isSliding){
                    play_img.source="qrc:/player/Images/player/滑铲1.png"
                }
                else if(isJumping){
                    play_img.source="qrc:/player/Images/player/跳跃1.png"
                }
                else if(isDowning){
                    play_img.source="qrc:/player/Images/player/跳跃2.png"
                }
                else{
                    if(zhengxiang){
                        currentImage=(currentImage+1)%run_images.length
                        if(currentImage===0){
                            zhengxiang=false
                            currentImage=3
                        }
                    }
                    else{
                        currentImage-=1
                        if(currentImage===0)
                            zhengxiang=true
                    }
                    play_img.source=run_images[currentImage]
                }
            }
        }
    }
}
