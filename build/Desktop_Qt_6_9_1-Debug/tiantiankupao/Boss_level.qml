import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Particles    //粒子特效

//BOSS关卡页面

Page{
    id:boss_level
    height:Screen.height
    width:Screen.width

    //系统属性：
    property int  sc_x:Screen.width/200
    property int  sc_y:Screen.height/100

    //地图属性
    property int  tileSize:Screen.height*0.1              //每个格子的大小
    property int  mapWidth:dungeonMap[0].length*tileSize  //地图宽度
    property int  mapHeight:dungeonMap.length*tileSize    //地图高度
    property int  viewportWidth:Screen.width              //用户视图宽度
    property int  viewportHeight:Screen.height            //用户试图高度
    property int  mapOffsetX:0                            //地图X偏移量
    property int  mapOffsetY:0                            //地图Y偏移量
    property bool init_player:true                        //初始化人物位置

    property var  dungeonMap:[                            //地牢地图矩阵
        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,1],
        [1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1],
        [1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1],
        [1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1],
        [1,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
    ]

    property int  speed:Screen.height*0.01                //移动速度

    //子弹属性
    property int  bullet_width:bullet_height              //子弹宽度
    property int  bullet_height:Screen.height*0.05        //子弹高度
    property int  bos_bltHeight:Screen.height*0.05        //boss子弹高度
    property int  bos_bltWidth:bos_bltHeight              //boss子弹宽度
    property real knockBackAngle:0                        //受击移动角度
    property bool isKnockback:false                       //是否被攻击后退

    //boss属性
    property int  boss_width:boss_height                  //boss宽度
    property int  boss_height:Screen.height*0.4           //boss高度

    //影分身属性
    property int  avatar_height:Screen.height*0.2         //分身高度
    property int  avatar_width:Screen.width*0.1           //分身宽度
    ListModel{ id:avatars }   //影分身容器

    //图片资源
    property string dizhuan:"qrc:/boss_level/Images/boss_level/地砖.png"
    property string qiangti:"qrc:/boss_level/Images/boss_level/墙体.png"

    //地图容器
    Item{
        id:mapContainer
        width:mapWidth
        height:mapHeight
        x:-mapOffsetX                 //当人物往右走也就相当于地图往坐走，所有跟地图父对象相关的x,y都会进行偏移
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

                        Image{
                            source:modelData ===1 ?qiangti:dizhuan
                            anchors.fill:parent
                        }

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
        color:"transparent"
        z:10
        Image{
            source:"qrc:/player/Images/player/页面图.png"
            anchors.fill:parent
        }

        //玩家在地图上的实际位置(人物中心点位置)
        property real worldX:(mapWidth-player.width)/2                              //人物所在地图X坐标
        property real worldY:mapHeight-tileSize-player.height/2      //人物所在地图Y坐标
        property real player_attackAngle:0                           //攻击方向
        property int  life:100                                       //人物生命值
    }

    //人物血条
    Rectangle{
        height:Screen.height*0.05;    width:Screen.width*0.2;
        color:"transparent";    z:10
        anchors{
            left:parent.left;    leftMargin: Screen.width*0.05
            top:parent.top;      topMargin:Screen.height*0.05
        }

        Rectangle{
            id:tupian;   height:parent.height;   width:height
            anchors.left:parent.left;    color:"transparent"
            anchors.verticalCenter: parent.verticalCenter
            Image{
                source:"qrc:/boss_level/Images/boss_level/生命.png" ;
                anchors.fill:parent
            }
        }

        Rectangle{
            height:parent.height;    width:parent.width*0.8
            border.width:1;     radius:width/2
            color:"transparent"
            anchors.left:tupian.right
            anchors.leftMargin: parent.width*0.03
            anchors.verticalCenter: parent.verticalCenter

            Label{
                z:10;  text:"生命值:"+player.life;    color:"black"
                anchors.centerIn: parent
            }

            Rectangle{
                height:parent.height;   width:parent.width*player.life/100
                border.width:1;     radius:height/2
                color:"red"
                anchors.left:parent.left; anchors.top:parent.top
            }
        }
    }

    //人物受击碰撞检测
    Timer{
        running:true
        repeat:true
        interval:16
        onTriggered: {
            for(var i=0;i<boss_bullet.count;i++){
                var bullet=gauiwu_bullet.itemAt(i)
                if(bullet.mapX>player.worldX-player.width/2 &&
                   bullet.mapX<player.worldX+player.width/2 &&
                   bullet.mapY>player.worldY-player.height/2 &&
                   bullet.mapY<player.worldY+player.height/2){
                    boss_bullet.remove(i)
                    player.life-=10
                    screenShake.start()           //受击振动
                    isKnockback=true              //被击退
                    player.worldX+=Math.cos(bullet.angle*Math.PI/180)*sc_y
                    player.worldY+=Math.sin(bullet.angle*Math.PI/180)*sc_y
                    updatePlayerPosition()
                    knockbacktimer.start()
                }
            }
        }
    }

    Timer{
        id:knockbacktimer
        interval:200
        onTriggered:  isKnockback=false
    }

    //人物受击屏幕振动动画
    SequentialAnimation{
        id:screenShake
        loops:2      //指定动画序列重复次数
        //晃动
        ParallelAnimation {
            NumberAnimation{
                target:boss_level;    property:"mapOffsetX"
                to:boss_level.mapOffsetX+sc_y*0.6;    duration:50
            }
            NumberAnimation{
                target:boss_level;    property:"mapOffsetY"
                to:boss_level.mapOffsetY+sc_y*0.6;    duration:50
            }
        }
        //恢复
        ParallelAnimation {
            NumberAnimation{
                target:boss_level;    property:"mapOffsetX"
                to:boss_level.mapOffsetX-sc_y*0.6;    duration:50
            }
            NumberAnimation{
                target:boss_level;    property:"mapOffsetY"
                to:boss_level.mapOffsetY-sc_y*0.6;    duration:50
            }
        }
    }

    //——————————————————————————————BOSS定义———————————————————————————
    Rectangle{
        id:boss
        height:boss_level.boss_height
        width:boss_level.boss_width
        border.width:1
        visible:!boss.isDead

        x:boss_mapX-mapOffsetX      //考虑地图偏移
        y:boss_mapY-mapOffsetY

        property int  boss_mapX:(mapWidth-boss.width)/2     //boss在地图上的x坐标
        property int  boss_mapY:(mapHeight-boss.height)/2   //boss在地图上的y坐标
        property int  boss_life:10                          //boss的血量
        property var  current_target:Qt.point(0,0)          //boss移动目标点
        property bool isMoving:false                        //boss是否正在移动
        property int  moveSpeed:Screen.height*0.01          //boss移动速度
        property bool isDead:false                          //boss是否死亡

        //boss攻击状态
        property var attackPattens:[
            {
                name:"fan",cooldown:2000,
                execute:function() {fanshoot(5,60)}
            },
            {
                name:"circle",cooldown:2000,
                execute:function(){ circleShoot(20) }
            }
        ]

        Image{
            source:"qrc:/boss_level/Images/boss_level/boss.png"
            anchors.fill:parent
        }

        //boss移动
        Timer{
            id:bossMove
            interval:2000    //每2s重新选择一次目标
            running:!boss.isDead
            repeat:true
            onTriggered: {
                var newMapX=Math.random()*(mapWidth-boss.boss_mapX)
                var newMapY=Math.random()*(mapHeight-boss.boss_mapY)
                boss.current_target=Qt.point(newMapX,newMapY)
                boss.isMoving=true
            }
        }
        Behavior on boss_mapX {
            NumberAnimation{
                duration: boss.moveSpeed
                easing.type: Easing.InOutQuad   //动画效果开始加速，结束减速
            }
        }
        Behavior on boss_mapY{
            NumberAnimation{
                duration: boss.moveSpeed
                easing.type: Easing.InOutQuad   //动画效果开始加速，结束减速
            }
        }

        Timer{
            interval: 16
            running:boss.isMoving
            repeat:true
            onTriggered: {
                var dx=boss.current_target.x-boss.boss_mapX
                var dy=boss.current_target.y-boss.boss_mapY
                var distance=Math.sqrt(dx*dx+dy*dy)

                boss.boss_mapX+=(dx/distance)*boss.moveSpeed
                boss.boss_mapY+=(dy/distance)*boss.moveSpeed
                if(boss.boss_life<=0) boss.isDead=true
            }
        }
    }

    //boss血量显示
    Rectangle{
        height:Screen.height*0.05;    width:Screen.width*0.5;
        color:"transparent";    z:10
        visible:!boss.isDead
        anchors{
            top:parent.top
            topMargin: Screen.height*0.15
            horizontalCenter: parent.horizontalCenter
        }

        Rectangle{
            id:boss_xueliang;   height:parent.height;   width:height
            anchors.left:parent.left;    color:"transparent"
            anchors.verticalCenter: parent.verticalCenter

            Image{
                source:"qrc:/boss_level/Images/boss_level/boss血量.png" ;
                anchors.fill:parent
            }
        }

        Rectangle{
            height:parent.height;    width:parent.width*0.8
            border.width:1;     radius:width/2
            color:"transparent"
            anchors.left:boss_xueliang.right
            anchors.leftMargin: parent.width*0.03
            anchors.verticalCenter: parent.verticalCenter

            Label{
                z:10;  text:"生命值:"+boss.boss_life;    color:"black"
                anchors.centerIn: parent
            }

            Rectangle{
                height:parent.height;   width:parent.width*boss.boss_life/1000
                border.width:1;     radius:height/2
                color:"red"
                anchors.left:parent.left; anchors.top:parent.top
            }
        }
    }

    //boss死亡产生黑洞
    Rectangle{
        id:blackHole
        height:Screen.height*0.3;    width:height;  color:"transparent"
        property int mapX:(mapWidth-blackHole.width)/2
        property int mapY:(mapHeight-blackHole.height)/2
        visible:boss.isDead
        x:mapX-mapOffsetX
        y:mapY-mapOffsetY
        Image{
            source:"qrc:/boss_level/Images/boss_level/黑洞.png"
            anchors.fill:parent
            rotation:0    //设置图片初始旋转角度
            //持续旋转效果
            RotationAnimation on rotation{
                from:0;   to:360;  duration:1000
                loops:Animation.Infinite
            }
        }
    }

    //boss攻击设置
    Repeater{
        id:gauiwu_bullet
        model:ListModel{id:boss_bullet}
        delegate: Rectangle{
            id:guaiwu_blt
            width:bos_bltWidth
            height:bos_bltHeight
            property int mapX:model.mapX
            property int mapY:model.mapY
            x:mapX-mapOffsetX
            y:mapY-mapOffsetY
            radius:width/2
            color:"yellow"

            property real speed:5
            property real angle:model.angle          //偏移角度
            property int  damage:10                  //伤害

            //子弹移动
            Timer{
                interval:16
                running:true
                repeat:true
                onTriggered: {
                    guaiwu_blt.mapX+=Math.cos(guaiwu_blt.angle*Math.PI/180)*guaiwu_blt.speed
                    guaiwu_blt.mapY+=Math.sin(guaiwu_blt.angle*Math.PI/180)*guaiwu_blt.speed

                    //超出边界后损坏
                    if(guaiwu_blt.mapX<0 || guaiwu_blt.mapX>mapWidth-tileSize ||
                       guaiwu_blt.mapY<0 || guaiwu_blt.mapY>mapHeight-tileSize){
                        boss_bullet.remove(index)
                    }
                    //撞墙毁坏
                    if(!isWalkable(guaiwu_blt.mapX,guaiwu_blt.mapY)){
                        boss_bullet.remove(index)
                    }
                }
            }
        }
    }

    //子弹生成函数
    function createBullet(angle){
        boss_bullet.append({
            "mapX":boss.boss_mapX- bos_bltWidth/2,
            "mapY":boss.boss_mapY-bos_bltHeight/2,
            "angle":angle
        })
    }

    //扇形散射攻击
    function fanshoot(count,spread){
        var angle=angleToPlayer()
        for(var i=0;i<count;i++){
            var bulletAngle=angle-spread/2+(i*spread/(count-1))
            createBullet(bulletAngle)
        }
    }

    //环形弹幕攻击
    function circleShoot(count){
        for(var i=0;i<count;i++){
            var angle_l=i*(360/count)
            createBullet(angle_l)
        }
    }

    //指向人物的角度
    function angleToPlayer(){
        var dx=player.worldX-boss.boss_mapX
        var dy=player.worldY-boss.boss_mapY
        return Math.atan2(dy,dx)*180/Math.PI
    }

    Timer{
        id:bos_atcTimer
        interval:2000    //2s一次攻击
        running:!boss.isDead
        repeat:true
        onTriggered: {
            var patten=boss.attackPattens[Math.floor(Math.random()*boss.attackPattens.length)]
            patten.execute()

            interval=patten.cooldown*(0.8+Math.random()*0.4)
        }
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
        MultiPointTouchArea {
            anchors.fill: parent
            minimumTouchPoints: 1
            maximumTouchPoints: 3

            touchPoints: [
                TouchPoint{
                    id:touchpoint1
                    onPressedChanged:{
                        if(!pressed){
                            joystick_Knob.x = joystick_Base.x+(joystick_Base.width-joystick_Knob.width)/2
                            joystick_Knob.y = joystick_Base.y+(joystick_Base.height-joystick_Knob.height)/2
                            joystick_Knob.directionX = 0
                            joystick_Knob.directionY = 0
                        }
                        else{
                            updateJoystick(x,y)
                        }
                    }
                    onXChanged: if (pressed) updateJoystick(touchpoint1.x,touchpoint1.y)
                    onYChanged: if (pressed) updateJoystick(touchpoint1.x,touchpoint1.y)

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
                        player.player_attackAngle=Math.atan2(dy,dx)*180/Math.PI
                    }
                }
            ]
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
            color:"transparent"

            Image{
                source:"qrc:/boss_level/Images/boss_level/攻击.png"
                anchors.fill:parent
            }
        }

        MouseArea{
            anchors.fill:parent
            preventStealing: false
            onPressed:{
                update_attackCT(mouseX,mouseY)
            }
            onPositionChanged:{
                update_attackCT(mouseX,mouseY)
            }
            onReleased: {
                attackCT.x=attackBG.x+attackBG.width*0.75/2
                attackCT.y=attackBG.y+attackBG.height*0.75/2
                attackControl.move_attackAngle=0
                attackControl.isAttacking=false
            }

            function update_attackCT(mouseX,mouseY){
                attackControl.isAttacking=true
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

                attackControl.move_attackAngle=Math.atan2(dy,dx)*180/Math.PI
            }
        }  
    }

    //——————————————————————————————技能按钮————————————————————————————
    Item{
        id:skill
        height:Screen.height*0.15;    width:height
        property int skill_coolDown:8               //冷却时常
        property bool can_use:true                  //是否能使用
        anchors{
            bottom:parent.bottom;   bottomMargin: Screen.height*0.08;
            right:attackControl.left;   rightMargin:Screen.width*0.05
        }
        Rectangle{
            height:parent.height;   width:parent.width;
            border.width:1;     color:"lightgray";    radius:height/2
            opacity:0.5
            Image{
                source:"qrc:/boss_level/Images/boss_level/闪电.png"
                anchors.fill:parent
            }
        }
        Button{
            anchors.fill:parent
            background: Rectangle{ color:"transparent" }
            onClicked: {
                if(skill.can_use){
                    generateAvatar()
                    skill.can_use=false
                    skill.skill_coolDown=8
                }
            }
        }
        Label{
            text:skill.can_use?" ":skill.skill_coolDown;
            color:"black"
            anchors.centerIn:parent
        }

        Timer{
            interval:1000       //1s
            repeat:true
            running:!skill.can_use
            onTriggered: {
                if(skill.skill_coolDown>0) skill.skill_coolDown--
                if(skill.skill_coolDown===0) skill.can_use=true
            }
        }
    }

    //生成影分身
    function generateAvatar(){
        var avatar1_mapX=player.worldX-player.width/2-avatar_width/2
        var avatar1_mapY=player.worldY
        avatars.append({
            "mapX":avatar1_mapX,
            "mapY":avatar1_mapY
        })

        var avatar2_mapX=player.worldX+player.width/2+avatar_width/2
        var avatar2_mapY=player.worldY
        avatars.append({
            "mapX":avatar2_mapX,
            "mapY":avatar2_mapY
        })
    }

    //索敌boss
    function angleToBoss(ava_mapX,ava_mapY){
        var dx=boss.boss_mapX-ava_mapX;     var dy=boss.boss_mapY-ava_mapY
        return Math.atan2(dy,dx)*180/Math.PI
    }

    //影分身
    Repeater{
        id:avatar_rpt
        model:avatars
        delegate:Rectangle{
            id:avatar
            width:avatar_width
            height:avatar_height
            property int mapX:model.mapX
            property int mapY:model.mapY
            x:mapX-avatar_width/2-mapOffsetX
            y:mapY-avatar_height/2-mapOffsetY
            color:"transparent"

            property int life:200              //生命值
            property int attack:3              //攻击力
            property bool moveToBoss:true      //向boss移动
            property int speed:sc_y            //移速

            Image{
                source:"qrc:/boss_level/Images/boss_level/分身.png"
                anchors.fill:parent
                fillMode: Image.PreserveAspectFit
            }

            Timer{
                interval:16
                running:true
                repeat:true
                onTriggered: {
                    var angle=angleToBoss(avatar.mapX,avatar.mapY)
                    //追踪boss
                    if(avatar.moveToBoss){
                        ava_atc.stop()
                        avatar.mapX+=Math.cos(angle*Math.PI/180)*avatar.speed
                        avatar.mapY+=Math.sin(angle*Math.PI/180)*avatar.speed
                    }
                    if(avatar.mapX>boss.boss_mapX-boss.width/2 &&
                       avatar.mapX<boss.boss_mapX+boss.width/2 &&
                       avatar.mapY>boss.boss_mapY-boss.height/2 &&
                       avatar.mapY<boss.boss_mapY+boss.height/2){
                        avatar.moveToBoss=false
                        ava_atc.start()
                    }
                    else avatar.moveToBoss=true

                    //受击碰撞检测
                    for(var i=0;i<boss_bullet.count;i++){
                        var bullet=gauiwu_bullet.itemAt(i)
                        if(bullet.mapX>avatar.mapX-avatar.width/2 &&
                           bullet.mapX<avatar.mapX+avatar.width/2 &&
                           bullet.mapY>avatar.mapY-avatar.height/2 &&
                           bullet.mapY<avatar.mapY+avatar.height/2){
                            boss_bullet.remove(i)
                            avatar.life-=10
                        }
                    }
                    //死亡
                    if(avatar.life<=0)avatars.remove(index)
                }
            }
            //攻击计时器
            Timer{
                id:ava_atc
                repeat:true
                interval:500      //每0.5s攻击一次
                onTriggered: {
                    boss.boss_life-=3
                }
            }
        }
    }


    //子弹管理器
    Repeater{
        id:bulletRepeater
        model:ListModel{ id:bulletModel }
        delegate:Rectangle{
            id:bullet
            width:bullet_width
            height:bullet_height
            color:"transparent"
            x:bullet_mapX-mapOffsetX          //从人物中心开始移动
            y:bullet_mapY-mapOffsetY

            property int  bullet_mapX:model.mapX      //子弹在地图中的X位置
            property int  bullet_mapY:model.mapY      //子弹在地图中的Y位置
            property real speed:5
            property real angle:model.angle

            Image{
                source:"qrc:/boss_level/Images/boss_level/手里剑.png"
                anchors.fill:parent
            }

            //子弹移动
            Timer{
                interval:16
                running:true
                repeat:true
                onTriggered: {
                    //调整子弹位置
                    bullet.bullet_mapX+=Math.cos(bullet.angle*Math.PI/180)*bullet.speed
                    bullet.bullet_mapY+=Math.sin(bullet.angle*Math.PI/180)*bullet.speed
                    //移除超过地图容器的子弹
                    if(bullet.bullet_mapX<0 || bullet.bullet_mapX+bullet.width>mapWidth ||
                       bullet.bullet_mapY<0 || bullet.bullet_mapY+bullet.height>mapHeight){
                        bulletModel.remove(index)
                    }
                    //移除撞墙子弹
                    if(!isWalkable(bullet.bullet_mapX,bullet.bullet_mapY)){
                        bulletModel.remove(index)
                    }
                }
            }
        }
    }

    //子弹生成器
    Timer{
        id:attackTimer
        interval:200
        repeat:true
        running:attackControl.isAttacking
        onTriggered: {
            //子弹初始地图坐标
            var bulletStartX=player.worldX
            var bulletStartY=player.worldY

            var angleRad=attackControl.move_attackAngle*Math.PI/180
            var halfWidth=player.width/2
            var halfHeight=player.height/2

            var offsetX=Math.cos(angleRad)*halfWidth
            var offsetY=Math.sin(angleRad)*halfHeight

            bulletModel.append({
                "mapX":bulletStartX+offsetX,
                "mapY":bulletStartY+offsetY,
                "angle":attackControl.move_attackAngle
            })
        }
    }

    //子弹碰撞检测
    function attackOnBoss(){
        for(var i=0;i<bulletModel.count;i++){
            var current_blt=bulletRepeater.itemAt(i)
            if(current_blt.bullet_mapX >boss.boss_mapX &&
               current_blt.bullet_mapX <boss.boss_mapX+boss.width &&
               current_blt.bullet_mapY >boss.boss_mapY &&
               current_blt.bullet_mapY <boss.boss_mapY+boss.height){
                console.log("触发")
                boss.boss_life--
                bulletModel.remove(i)
            }
        }
    }

    //游戏主计时器
    Timer{
        id:updata_player
        interval:8
        running:true
        repeat:true
        onTriggered: {
            //更新玩家位置
            updatePlayerPosition()
            //子弹与boss碰撞检测
            attackOnBoss()
            if(player.life===0){

            }
        }
    }

    // 更新玩家位置
    function updatePlayerPosition() {
        if(init_player){
            //初始化人物位置
            mapOffsetX = player.worldX - viewportWidth / 2
            mapOffsetY = player.worldY - viewportHeight / 2
        }
        if(isKnockback){
            mapOffsetX = player.worldX - viewportWidth / 2
            mapOffsetY = player.worldY - viewportHeight / 2
            return
        }
        //当被攻击击退时不会更新玩家位置

        if (Math.abs(joystick_Knob.directionX) > 0.1 ||
            Math.abs(joystick_Knob.directionY) > 0.1) {

            init_player=false
            //更新玩家在世界中的位置
            var moveX=joystick_Knob.directionX*speed
            var moveY=joystick_Knob.directionY*speed

            //检测X轴
            if(moveX!==0){
                var newWorldX=player.worldX+moveX
                if(checkPlayerCollision(newWorldX,player.worldY,moveX>0?"right":"left")){
                    player.worldX=newWorldX
                }
            }
            //检测Y轴
            if(moveY!==0){
                var newWorldY=player.worldY+moveY
                if(checkPlayerCollision(player.worldX,newWorldY,moveY>0?"down":"up")){
                    player.worldY=newWorldY
                }
            }

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

    //检测墙体是否可通过
    function isWalkable(mapX,mapY){
        var tileX=Math.floor(mapX/tileSize)
        var tileY=Math.floor(mapY/tileSize)
        return dungeonMap[tileY][tileX] !==1
    }

    //检测人物矩形是否与墙体碰撞
    function checkPlayerCollision(newWorldX,newWorldY,direction){
        var points=[]
        var halfWidth=player.width/2
        var halfHeight=player.height/2

        switch(direction){
        case "left":
            points=[
                Qt.point(newWorldX-halfWidth,newWorldY-halfHeight),
                Qt.point(newWorldX-halfWidth,newWorldY),
                Qt.point(newWorldX-halfWidth,newWorldY+halfHeight),
            ]
            break
        case "right":
            points=[
                Qt.point(newWorldX+halfWidth,newWorldY-halfHeight),
                Qt.point(newWorldX+halfWidth,newWorldY),
                Qt.point(newWorldX+halfWidth,newWorldY+halfHeight),
            ]
            break
        case "up":
            points=[
                Qt.point(newWorldX-halfWidth,newWorldY-halfHeight),
                Qt.point(newWorldX,newWorldY-halfHeight),
                Qt.point(newWorldX+halfWidth,newWorldY-halfHeight),
            ]
            break
        case "down":
            points=[
                Qt.point(newWorldX-halfWidth,newWorldY+halfHeight),
                Qt.point(newWorldX,newWorldY+halfHeight),
                Qt.point(newWorldX+halfWidth,newWorldY+halfHeight),
            ]
            break
        }

        for(var i=0;i<points.length;i++){
            if(!isWalkable(points[i].x,points[i].y)){
                return false
            }
        }
        return true
    }
}

