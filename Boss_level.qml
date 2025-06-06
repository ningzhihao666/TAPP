import QtQuick
import QtQuick.Controls
import QtQuick.Window

//BOSS关卡页面

Page{
    height:Screen.height
    width:Screen.width

    //地图属性
    property int tileSize:Screen.height*0.1              //每个格子的大小
    property int mapWidth:dungeonMap[0].length*tileSize  //地图宽度
    property int mapHeight:dungeonMap.length*tileSize    //地图高度
    property int viewportWidth:Screen.width              //用户视图宽度
    property int viewportHeight:Screen.height            //用户试图高度
    property int mapOffsetX:0                            //地图X偏移量
    property int mapOffsetY:0                            //地图Y偏移量

    property var dungeonMap:[                            //地牢地图矩阵
        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
    ]

    property int speed:5                                 //移动速度

    //图片资源
    property string dizhuan:"qrc:/boss_level/Images/boss_level/地砖.png"

    //地图容器
    Item{
        id:mapContainer
        width:mapWidth
        height:mapHeight
        x:-mapOffsetX
        y:-mapOffsetY

        //绘制地牢地图
        Repeater{
            model:dungeonMap
            delegate:Row{
                y:index*tileSize
                Repeater{
                    model:dungeonMap[index]
                    Rectangle{
                        width:tileSize
                        height: tileSize
                        color:modelData ===1?"gray":"green"
                    }
                }
            }
        }
    }

    //——————————————————————————————定义角色————————————————————————————
    Rectangle{
        id:player                      //位于屏幕中央
        width:Screen.width*0.1
        height:Screen.height*0.2
        x:Screen.width/2-width/2
        y:Screen.height/2-height/2
        z:10
        Image{
            source:"qrc:/player/Images/player/页面图.png"
            anchors.fill:parent
        }

        //玩家在地图上的实际位置(人物中心点位置)
        property real worldX:mapWidth/2                  //人物所在地图X坐标
        property real worldY:mapHeight/2                 //人物所在地图Y坐标
        property real player_attackAngle:0                      //攻击方向
    }

    //——————————————————————————————移动轮盘————————————————————————————
    Item{
        id:joystick
        height:Screen.height*0.25
        width:height
        anchors{
            bottom:parent.bottom;   bottomMargin: Screen.height*0.08;
            left:parent.left;   leftMargin:Screen.width*0.05
        }

        //遥感外框
        Rectangle{
            id:joystick_Base
            width:parent.width
            height:parent.height
            color:"lightgray"
            radius:width/2
            opacity:0.5      //控制透明度
        }

        //遥感内框
        Rectangle{
            id:joystick_Knob
            width:parent.width*0.5
            height:parent.height*0.5
            color:"darkgray"
            radius:width*0.5
            x:joystick_Base.x+(joystick_Base.width-joystick_Knob.width)/2
            y:joystick_Base.y+(joystick_Base.height-joystick_Knob.height)/2

            property real maxDistance: joystick_Base.width*0.5
            property real directionX: 0
            property real directionY: 0
        }

        // 摇杆控制区域
        MouseArea {
            id: joystickArea
            anchors.fill: parent
            preventStealing: true    //防止事件丢失给父对象

            onPressed: updateJoystick(mouseX, mouseY)
            onPositionChanged: updateJoystick(mouseX, mouseY)
            onReleased: {
                joystick_Knob.x = joystick_Base.x+(joystick_Base.width-joystick_Knob.width)/2
                joystick_Knob.y = joystick_Base.y+(joystick_Base.height-joystick_Knob.height)/2
                joystick_Knob.directionX = 0
                joystick_Knob.directionY = 0
            }

            function updateJoystick(mouseX, mouseY) {
                var centerX = joystick_Base.x+joystick_Base.width / 2
                var centerY = joystick_Base.y+joystick_Base.height / 2
                var dx = mouseX - centerX
                var dy = mouseY - centerY
                var distance = Math.sqrt(dx * dx + dy * dy)

                // 限制摇杆移动范围
                if (distance > joystick_Knob.maxDistance) {
                    dx = dx * joystick_Knob.maxDistance / distance
                    dy = dy * joystick_Knob.maxDistance / distance
                }

                joystick_Knob.x = dx+joystick_Base.x+(joystick_Base.width-joystick_Knob.width)/2
                joystick_Knob.y = dy+joystick_Base.y+(joystick_Base.height-joystick_Knob.height)/2

                // 标准化方向向量
                if (distance > 0) {
                    joystick_Knob.directionX = dx / joystick_Knob.maxDistance
                    joystick_Knob.directionY = dy / joystick_Knob.maxDistance
                } else {
                    joystick_Knob.directionX = 0
                    joystick_Knob.directionY = 0
                }

                // 更新人物攻击方向
                player.player_attackAngle=Math.atan2(dx,dy)*180/Math.PI
            }
        }
    }

    //——————————————————————————————攻击按钮————————————————————————————
    Item{
        id:attackControl
        height:Screen.height*0.25
        width:height
        anchors{
            bottom:parent.bottom;   bottomMargin: Screen.height*0.08;
            right:parent.right;   rightMargin:Screen.width*0.05
        }

        property point attackDirection:Qt.point(0,0)         //攻击方向
        property bool isAttacking:false                      //是否发动攻击
        property real maxDistance:attackControl.width/2      //遥杆最远距离
        property real move_attackAngle:0                     //攻击角度

        //外框
        Rectangle{
            id:attackBG
            anchors.fill:parent
            radius:width/2
            color:"lightgray"
            opacity:0.5
        }
        //内点
        Rectangle{
            id:attackCT
            x:attackBG.x+attackBG.width*0.75/2
            y:attackBG.y+attackBG.height*0.75/2
            width:attackBG.width/4
            height:attackBG.height/4
            color:"darkgray"
        }

        MouseArea{
            anchors.fill:parent
            onPressed:{
                update_attackCT(mouseX,mouseY)
            }
            onPositionChanged:{
                update_attackCT(mouseX,mouseY)
                //if(pressed){
                //
                //}
            }
            onReleased: {
                attackCT.x=attackBG.x+attackBG.width*0.75/2
                attackCT.y=attackBG.y+attackBG.height*0.75/2
                attackControl.move_attackAngle=0
            }

            function update_attackCT(mouseX,mouseY){
                var centerX=attackBG.x+attackBG.width/2
                var centerY=attackBG.y+attackBG.height/2
                var dx=mouseX-centerX
                var dy=mouseY-centerY
                var distance=Math.sqrt(dx*dx+dy*dy)

                if(distance>attackControl.maxDistance){
                    dx=dx*attackControl.maxDistance/distance
                    dy=dy*attackControl.maxDistance/distance
                }

                attackCT.x=attackBG.x+attackBG.width*0.75/2+dx
                attackCT.y=attackBG.y+attackBG.height*0.75/2+dy

                attackControl.move_attackAngle=Math.atan2(dx,dy)*180/Math.PI
            }
        }  
    }

    //子弹管理器


    //计时器更新玩家位置
    Timer{
        id:updata_player
        interval:8
        running:true
        repeat:true
        onTriggered: {
            updatePlayerPosition()
        }
    }

    // 更新玩家位置
    function updatePlayerPosition() {
        if (Math.abs(joystick_Knob.directionX) > 0.1 ||
            Math.abs(joystick_Knob.directionY) > 0.1) {

            //更新玩家在世界中的位置
            player.worldX+=joystick_Knob.directionX*speed
            player.worldY+=joystick_Knob.directionY*speed

            //限制人物在围墙内
            if(player.worldX-player.width/2<tileSize) player.worldX=tileSize+player.width/2
            if(player.worldX+player.width/2>mapWidth-tileSize) player.worldX=mapWidth-tileSize-player.width/2
            if(player.worldY-player.height/2<tileSize) player.worldY=tileSize+player.height/2
            if(player.worldY+player.height/2>mapHeight-tileSize) player.worldY=mapHeight-tileSize-player.height/2

            // 计算地图偏移，使玩家保持在屏幕中心
            mapOffsetX = player.worldX - viewportWidth / 2
            mapOffsetY = player.worldY - viewportHeight / 2
        }
    }

}
