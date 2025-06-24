import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts
import QtMultimedia

//设置页面

Page{
    id:settings

    property int thumId:1                       //主题号
    property int musicId:1                      //音乐号

    property string music1:"qrc:/musics/musics/两难.mp3"
    property string music2:"qrc:/musics/musics/My Heart Will Go On.mp3"
    property string music3:"qrc:/musics/musics/无法忘记你.mp3"
    property string music4:"qrc:/musics/musics/没成功前说什么都像借口.mp3"
    property string music5:"qrc:/musics/musics/病变.mp3"
    property string music6:"qrc:/musics/musics/跳楼机.mp3"
    property string music7:"qrc:/musics/musics/这次你真的走了.mp3"
    property string music8:"qrc:/musics/musics/那个男孩.mp3"
    property string music9:"qrc:/musics/musics/阳光开朗大男孩.mp3"

    Image{
        source:"qrc:/page_settings/Images/page_settings/背景.jpg"
        anchors.fill:parent
    }

    MediaPlayer {
        id:mediaplayer
        audioOutput: AudioOutput { volume:1 }
        source: "qrc:/musics/musics/两难.mp3"
        loops:MediaPlayer.Infinite
    }

    ButtonGroup{
        id:themeGroup
        exclusive:true    //确保互斥
    }
    ButtonGroup{
        id:musicGroup
        exclusive:true    //确保互斥
    }

    Label{
        text:"设置页面";  font.pixelSize: Screen.height*0.04 ;  color:"lightyellow"
        anchors{
            top:parent.top;   topMargin: Screen.height*0.03
            horizontalCenter: parent.horizontalCenter
        }
    }

    //返回按钮
    Button{
        height:Screen.height*0.08;    width:Screen.width*0.08
        background: Rectangle{ color:"transparent"}
        onClicked: { stackView.pop() }
        anchors{
            top:parent.top;   topMargin: Screen.height*0.05
            left:parent.left;    leftMargin:Screen.width*0.02
        }
        Image{
            source:"qrc:/page_settings/Images/page_settings/返回.png"
            anchors.fill:parent
            fillMode:Image.PreserveAspectFit
        }
    }

    //应用新设置
    Button{
        height:Screen.height*0.1;    width:Screen.width*0.1;
        background: Rectangle{ color:"yellow"; border.width:1; radius:width/8}
        onClicked: { stackView.replace("Page_begin.qml",{
                                       "thumId":thumId,
                                       "musicId":musicId
                                       }) }
        anchors{
            bottom:parent.bottom;   bottomMargin: Screen.height*0.01
            horizontalCenter: parent.horizontalCenter
        }
        Label{
            text:"应用新设置";   color:"black"
            anchors.centerIn: parent
        }
    }



    //主题
    Button{
        id:zhuti
        height:Screen.height*0.1;    width:Screen.width*0.15
        background: Rectangle{ color:"lightblue"; border.width:1; radius:5}
        onClicked: {
            zhuti_control.visible=true
            music_control.visible=false
        }
        anchors{
            top:parent.top;   topMargin: Screen.height*0.2
            left:parent.left;    leftMargin:Screen.width*0.05
        }
        Label{
            text:"主题";   color:"black"
            anchors.centerIn: parent
        }
    }

    //音乐
    Button{
        id:music
        height:Screen.height*0.1;    width:Screen.width*0.15
        background: Rectangle{ color:"lightblue"; border.width:1; radius:5}
        onClicked: {
            zhuti_control.visible=false
            music_control.visible=true
        }
        anchors{
            top:zhuti.bottom;   topMargin: Screen.height*0.15
            left:parent.left;    leftMargin:Screen.width*0.05
        }
        Label{
            text:"音乐";   color:"black"
            anchors.centerIn: parent
        }
    }

    //音乐
    Button{
        id:quit
        height:Screen.height*0.1;    width:Screen.width*0.15
        background: Rectangle{ color:"lightblue"; border.width:1; radius:5}
        onClicked: {
            Qt.quit()
        }
        anchors{
            top:music.bottom;   topMargin: Screen.height*0.15
            left:parent.left;    leftMargin:Screen.width*0.05
        }
        Label{
            text:"退出";   color:"black"
            anchors.centerIn: parent
        }
    }



    //主题控制页面
    Rectangle{
        id:zhuti_control
        height:Screen.height*0.8;  width:Screen.width*0.7;  border.width:1
        radius:width*0.1;   color:"lightblue";    visible:false
        anchors{
            left:zhuti.right;   leftMargin: Screen.width*0.05
            verticalCenter: parent.verticalCenter
        }
        ListView{
            anchors.fill:parent
            Label{
                text:"主题选择";   color:"lightyellow";  font.pixelSize: Screen.height*0.04
                anchors{
                    top:parent.top;  topMargin: parent.height*0.03
                    horizontalCenter: parent.horizontalCenter
                }
            }
            Rectangle{
                height:parent.height*0.05;   width:parent.width*0.2;  border.width:1
                color:"lightblue";   radius:width*0.1
                Label{
                    text:"请选择你的天天酷跑主题";   color:"lightyellow";  font.pixelSize: Screen.height*0.02
                    anchors.centerIn:parent
                }
                anchors{
                    top:parent.top;  topMargin: parent.height*0.15
                    left:parent.left;   leftMargin: parent.width*0.05
                }
            }

            //主题1：春江花月
            Rectangle{
                id:thum1
                height:parent.height*0.3;   width:parent.width*0.4;   border.width:1
                color:"lightblue";   radius:width*0.1
                anchors{
                    top:parent.top;  topMargin: parent.height*0.25
                    left:parent.left;   leftMargin: parent.width*0.05
                }
                RadioButton{
                    anchors{bottom: parent.bottom;  horizontalCenter: parent.horizontalCenter}
                    ButtonGroup.group: themeGroup
                    onClicked: { thumId=1 }
                }
                Label{
                    text:"春江花月";   color:"lightyellow"; font.pixelSize: Screen.height*0.02
                    anchors{ top:parent.top; horizontalCenter: parent.horizontalCenter}
                }
                Image{
                    height:parent.height*0.8;  width:parent.width*0.8
                    source:"qrc:/page_settings/Images/page_settings/春江花月.jpg"
                    anchors.centerIn: parent
                }

            }

            //主题2：皮卡丘
            Rectangle{
                id:thum2
                height:parent.height*0.3;   width:parent.width*0.4;   border.width:1
                color:"lightblue";   radius:width*0.1
                anchors{
                    top:parent.top;  topMargin: parent.height*0.25
                    left:thum1.right;   leftMargin: parent.width*0.05
                }
                RadioButton{
                    anchors{
                        bottom: parent.bottom;  horizontalCenter: parent.horizontalCenter
                    }
                    ButtonGroup.group: themeGroup
                    onClicked: { thumId=2 }
                }
                Label{
                    text:"皮卡丘";   color:"lightyellow"; font.pixelSize: Screen.height*0.02
                    anchors{
                        top:parent.top; horizontalCenter: parent.horizontalCenter
                    }
                }
                Image{
                    height:parent.height*0.8;  width:parent.width*0.8
                    source:"qrc:/page_settings/Images/page_settings/皮卡丘.jpg"
                    anchors.centerIn: parent
                }

            }

            //主题3：线条小狗
            Rectangle{
                id:thum3
                height:parent.height*0.3;   width:parent.width*0.4;   border.width:1
                color:"lightblue";   radius:width*0.1
                anchors{
                    top:thum1.bottom;  topMargin: parent.height*0.05
                    left:parent.left;   leftMargin: parent.width*0.05
                }
                RadioButton{
                    anchors{
                        bottom: parent.bottom;  horizontalCenter: parent.horizontalCenter
                    }
                    ButtonGroup.group: themeGroup
                    onClicked: { thumId=3 }
                }
                Label{
                    text:"线条小狗";   color:"lightyellow"; font.pixelSize: Screen.height*0.02
                    anchors{
                        top:parent.top; horizontalCenter: parent.horizontalCenter
                    }
                }
                Image{
                    height:parent.height*0.8;  width:parent.width*0.8
                    source:"qrc:/page_settings/Images/page_settings/线条小狗.jpg"
                    anchors.centerIn: parent
                }
            }

            //主题4：星空下的约定
            Rectangle{
                id:thum4
                height:parent.height*0.3;   width:parent.width*0.4;   border.width:1
                color:"lightblue";   radius:width*0.1
                anchors{
                    top:thum1.bottom;  topMargin: parent.height*0.05
                    left:thum3.right;   leftMargin: parent.width*0.05
                }
                RadioButton{
                    anchors{
                        bottom: parent.bottom;  horizontalCenter: parent.horizontalCenter
                    }
                    ButtonGroup.group: themeGroup
                    onClicked: { thumId=4 }
                }
                Label{
                    text:"星空下的约定";   color:"lightyellow"; font.pixelSize: Screen.height*0.02
                    anchors{
                        top:parent.top; horizontalCenter: parent.horizontalCenter
                    }
                }
                Image{
                    height:parent.height*0.8;  width:parent.width*0.8
                    source:"qrc:/page_settings/Images/page_settings/星空下的约定.jpg"
                    anchors.centerIn: parent
                }
            }
        }
    }

    //音乐控制选择页面
    Rectangle{
        id:music_control
        height:Screen.height*0.8;  width:Screen.width*0.7;  border.width:1
        radius:width*0.1;   color:"lightblue"
        anchors{
            left:zhuti.right;   leftMargin: Screen.width*0.05
            verticalCenter: parent.verticalCenter
        }
        Label{
            text:"背景音乐选择";   color:"lightyellow";  font.pixelSize: Screen.height*0.04
            anchors{
                top:parent.top;  topMargin: parent.height*0.03
                horizontalCenter: parent.horizontalCenter
            }
        }
        Rectangle{
            id:music_ls
            height:parent.height*0.05;   width:parent.width*0.2;  border.width:1
            color:"lightblue";   radius:width*0.1
            Label{
                text:"请选择你的游戏背景音乐";   color:"lightyellow";  font.pixelSize: Screen.height*0.02
                anchors.centerIn:parent
            }
            anchors{
                top:parent.top;  topMargin: parent.height*0.15
                left:parent.left;   leftMargin: parent.width*0.05
            }
        }
        ListView{
            height:parent.height*0.6;  width:parent.width*0.8;
            spacing:10
            anchors{
                top:music_ls.bottom;  topMargin: parent.height*0.05
                left:parent.left;  leftMargin: parent.width*0.05
            }
            model:["两难","My Heart Will Go On","无法忘记你","没成功前说什么都像借口","病变",
                   "跳楼机","这次你真的走了","那个男孩","阳光开朗大男孩"]
            delegate:Rectangle{
                height:music_control.height*0.1; width:music_control.width*0.9
                radius:width/8;  color:"lightblue";   border.width:1

                RowLayout{
                    anchors.fill:parent
                    spacing:Screen.height*0.01
                    RadioButton{
                        Layout.preferredWidth: parent.width*0.1
                        anchors.verticalCenter: parent.verticalCenter
                        ButtonGroup.group:musicGroup
                        onClicked: {
                            musicId=index+1
                            chos_music(musicId)
                            console.log("musicId",musicId)
                        }
                    }
                    Label{
                        text:modelData;   color:"black"
                        font.pixelSize: Screen.height*0.02
                        Layout.fillWidth: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }

    function chos_music(index){
        switch (musicId){
        case 1:
            mediaplayer.source=music1
            mediaplayer.play()
            break;
        case 2:
            mediaplayer.source=music2
            mediaplayer.play()
            break;
        case 3:
            mediaplayer.source=music3
            mediaplayer.play()
            break;
        case 4:
            mediaplayer.source=music4
            mediaplayer.play()
            break;
        case 5:
            mediaplayer.source=music5
            mediaplayer.play()
            break;
        case 6:
            mediaplayer.source=music6
            mediaplayer.play()
            break;
        case 7:
            mediaplayer.source=music7
            mediaplayer.play()
            break;
        case 8:
            mediaplayer.source=music8
            mediaplayer.play()
            break;
        case 9:
            mediaplayer.source=music9
            mediaplayer.play()
            break;
        }
    }
}
