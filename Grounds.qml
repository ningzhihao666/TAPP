import QtQuick
import QtQuick.Window
import QtQuick.Controls

//地面生成页面

Item {
    id:grounds
    property int sc_x: Screen.width/200
    property int sc_y: Screen.height/100

    property int playerPosition:sc_x*10    //玩家初始位置
    property bool running: false           //定义游戏是否开始

    //当前显示地面列表
    ListModel{ id:activeGrounds }

    //地面生成函数
    function generateGround(){
        if(activeGrounds.count===0||activeGrounds.get(activeGrounds.count-1).x<playerPosition+Screen.width)
        {
            var lastGroundx=activeGrounds.count>0?activeGrounds.get(activeGrounds.count-1).x+sc_x*20:0;
            activeGrounds.append({
                "x":lastGroundx,
                "width":sc_x*20,
                "height":Screen.height/4
            });
        }
    }

    //记时同时不断生成地面
    Timer{
        interval:100      //每100ms毫秒更新
        running:grounds.running
        repeat:true
        onTriggered: { generateGround() }
    }

    //可视化
    Item{
        Repeater{
            model:activeGrounds
            delegate:Rectangle{
                x:model.x
                y:Screen.height-model.height
                width:model.width
                height:model.height

                Image{
                    source:"qrc:/BackGround/Images/BackGround/地面块.png"
                    anchors.fill:parent
                }
            }
        }
    }

}
