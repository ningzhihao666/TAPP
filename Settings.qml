import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts

//设置页面

Page{
    id:settings

    property int thumId:1                       //主题号

    Image{
        source:"qrc:/page_settings/Images/page_settings/背景.jpg"
        anchors.fill:parent
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
        height:Screen.height*0.05;    width:Screen.width*0.1;
        background: Rectangle{ color:"yellow"; border.width:1; radius:width/8}
        onClicked: { stackView.replace("Page_begin.qml",{
                                       "thumId":thumId
                                       }) }
        anchors{
            bottom:parent.bottom;   bottomMargin: Screen.height*0.02
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
        onClicked: { stackView.pop() }
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
        onClicked: { stackView.pop() }
        anchors{
            top:zhuti.bottom;   topMargin: Screen.height*0.15
            left:parent.left;    leftMargin:Screen.width*0.05
        }
        Label{
            text:"音乐";   color:"black"
            anchors.centerIn: parent
        }
    }

    ButtonGroup{
        id:themeGroup
        exclusive:true    //确保互斥
    }

    //主题控制页面
    Rectangle{
        id:zhuti_control
        height:Screen.height*0.8;  width:Screen.width*0.7;  border.width:1
        radius:width*0.1;   color:"lightblue"
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
}
