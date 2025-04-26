import QtQuick
import QtQuick.Controls
import QtQuick.Window

//游戏屏幕页面

Item {
    id: gameScreen
    width: Screen.width
    height: Screen.height

    //游戏特性
    property int  score: 0                                      //计算得分
    property int  distance:sc_x*10                              //计算距离
    property bool gameRunning: false                            //判定游戏是否开始
    property int  sc_x: Screen.width/200                        //屏幕横向划分为200份
    property int  sc_y: Screen.height/100                       //屏幕纵向划分为100份（因为手机横屏）
    property int  speed:5                                       //速度

    //地面块属性:
    property int  groundheight:Screen.height*4/5                //初始化地面高度为屏幕下方1/5
    property int  groundheight_top:Screen.height*3/5            //变化的最高高度
    property int  groundheight_buttom:Screen.height*5/6         //变化的最低高度
    property int  groundheight_next_top:Screen.height*4/5       //下一个地面块的顶部高度

    //玩家属性
    property int  player_x:sc_x*10
    property int  player_y:Screen.height*4/5-Screen.height/7
    property bool is_Dead:false                                 //判断是否死亡
    property bool isJumping:false                               //是否在跳跃
    property bool isSliding:false                               //是否滑铲
    property real jumpVelocity:1                                //跳跃速度
    property real gravity:4                                     //重力加速度
    property bool jump_isjump:false                             //判断人物是否向上跳跃
    property int  jump_top:Screen.height/7                      //跳跃的最大距离
    property int  nextground_x:1                                //下一个地面块的x坐标
    property int  nextground_top:Screen.height*4/5              //下一个地面块顶面top
    property bool need_jump:false                               //用于死亡条件1是否需要跳跃
    property bool on_ground:true                                //重力引擎判断条件

    // 游戏背景
    Image {
        source: "qrc:/BackGround/Images/BackGround/beijing1.png"
        anchors.fill: parent
    }

    //当前显示地面列表
    ListModel{ id:activeGrounds }

    //初始化地面
    Component.onCompleted: {
        for(var i=0;i<10;i++){
            generateGround(i*sc_x*20)
        }
    }

    //更新地面位置
    function generateGround(startX){
        var hasGap=Math.random()>0.9           //设立10%的概率为空缺
        var hasChange=Math.random()>0.8        //设立20%的概率为高度变化

        if(!hasGap){
            if(hasChange){
                if(groundheight<=groundheight_top)
                    groundheight+=Math.random()*20
                else if(groundheight>=groundheight_buttom)
                    groundheight-=Math.random()*20
                else
                    groundheight+=Math.random()*40-20
            }
        }
        else{
            groundheight=Screen.height
        }

        var newX=startX !==undefined?startX:(activeGrounds.count > 0 ? activeGrounds.get(activeGrounds.count-1).x + sc_x*20 : 0)

        activeGrounds.append({
        "x":newX,
        "width":sc_x*20,
        "height":Screen.height/3,
        "top":groundheight,          //用于判定地面的顶端
        "hasGap":hasGap
        });

        if(hasGap)     //恢复地面高度
            groundheight=Screen.height*4/5
    }

    //获取当前角色的地面块
    function get_CurrentGround()
    {
        for(var i=0;i<activeGrounds.count; i++)
        {
            var ground =activeGrounds.get(i)
            //检测角色是否在地面块上
            if((player_x+Screen.width/12>ground.x) && (player_x<ground.x+ground.width))
            {
                nextground_top=activeGrounds.get(i+1).top
                nextground_x=activeGrounds.get(i+1).x
                return ground
            }
        }
    }

    //人物跳跃
    function jump(){
        if(!isJumping  && !isSliding){
            isJumping=true
            jump_isjump=true
        }
    }

    //游戏主循环
    Timer{
        interval:16                               //60fps
        running:gameRunning&&!is_Dead
        repeat:true
        onTriggered:{
            distance+=speed;

            //移动地面
            for(var i=0;i<activeGrounds.count;i++)
            {
                activeGrounds.setProperty(i,"x",activeGrounds.get(i).x-speed)
            }

            //生成新地面段
            if(activeGrounds.count===0||activeGrounds.get(activeGrounds.count-1).x<player_x+Screen.width)
                generateGround()

            //移除超出屏幕地面段
            while(activeGrounds.count>0&&activeGrounds.get(0).x+sc_x*20<0)
                activeGrounds.remove(0)

            var ground=get_CurrentGround()

            //死亡条件1:被地面顶到左边屏幕外
            if((nextground_x-player_x-Screen.width/12)<0.1){
                console.log("nextground_top=",nextground_top)
                if(player_y+Screen.height/7>nextground_top){
                    need_jump=true
                    player_x-=speed
                    if(player_x<=0){      //死亡
                        gameOver()
                        return
                    }
                }
                else{
                    need_jump=false
                }
            }
            //恢复x位置
            if(!need_jump && player_x<sc_x*10){
                player_x+=speed
            }

            //跳跃逻辑处理
            if(isJumping)
            {
                var jumpVelocity_temp=jumpVelocity
                jumpVelocity_temp+=gravity
                jump_top-=jumpVelocity_temp
                player_y-=jumpVelocity_temp
                if(jump_top<=0){
                    isJumping=false
                    jump_top=Screen.height/7
                }
            }

            //重力引擎
            if(player_y+Screen.height/7<ground.top){
                on_ground=false
            }
            if(!isJumping && !on_ground){
                var jumpVelocity_temp=jumpVelocity
                jumpVelocity_temp+=gravity
                player_y+=jumpVelocity_temp
                if(player_y+Screen.height/7>=ground.top){
                    //死亡条件2
                    if(player_y+Screen.height/7>=Screen.height){
                        gameOver()
                        return
                    }
                    player_y=ground.top-Screen.height/7
                }
            }
        }
    }

    //滑铲计时器
    Timer{
        id:slideTimer
        interval:800
        onTriggered: isSliding=false
    }

    //可视化
    Item{
        Repeater{
            model:activeGrounds
            delegate:Rectangle{
                x:model.x
                y:model.top
                width:model.width
                height:model.height

                Image{
                    source:"qrc:/BackGround/Images/BackGround/地面块.png"
                    anchors.fill:parent
                }
            }
        }
    }

    // 玩家角色
    Player {
        id: player
        x: player_x
        y: player_y
    }



    // 跳跃和滑铲按钮
    Rectangle{
        height:Screen.height*0.2;   width:height;   radius:width/2
        border.width:1;  clip:true;    visible: gameRunning
        anchors{ bottom:parent.bottom;  bottomMargin: 5*sc_y;
            left:parent.left;   leftMargin: 10}
        Label{text:"跳跃"; color:"black";  anchors.centerIn:parent}
        Button{
            anchors.fill:parent
            background: Rectangle{color:"transparent"; radius:parent.radius
                clip:true}
            Image{
                height:parent.height;  width:parent.width
                source:"qrc:/player/Images/player/跳跃.png"
                anchors.centerIn:parent;   fillMode:Image.PreserveAspectCrop
            }

            onClicked:jump()
        }
        Label{text:"跳跃"; color:"black";  anchors.centerIn:parent}
    }

    Rectangle{
        height:Screen.height*0.2;   width:height;   radius:width/2
        border.width:1;  clip:true;    visible: gameRunning
        anchors{ bottom:parent.bottom;  bottomMargin: 5*sc_y;
            right:parent.right;   rightMargin: 10}
        Button{
            anchors.fill:parent
            background: Rectangle{color:"transparent"; radius:parent.radius
                clip:true}
            Image{
                height:parent.height;  width:parent.width
                source:"qrc:/player/Images/player/滑铲.png"
                anchors.centerIn:parent;   fillMode:Image.PreserveAspectCrop
            }

            onClicked:player.slide()
        }
        Label{text:"滑铲"; color:"black";  anchors.centerIn:parent}
    }



    //障碍物生成器
    //ObstacleGenerator {
    //    id: obstacleGenerator
    //    running: gameRunning
    //}

     //金币生成器
    //CoinGenerator {
    //    id: coinGenerator
    //    running: gameRunning
    //}

    //游戏控制面板
    GameControlPanel {
        score: gameScreen.score
        distance:gameScreen.distance
        gameRunning: gameScreen.gameRunning
        onStartGame: gameScreen.gameRunning = true
        onPauseGame: gameScreen.gameRunning = false
    }

    // 碰撞检测
    //CollisionDetector {
    //    player: player
    //    obstacles: obstacleGenerator.obstacles
    //    coins: coinGenerator.coins
    //    onCoinCollected: gameScreen.score += 10
    //    onObstacleHit: gameOver()
    //}

    function gameOver() {
        is_Dead=true
        gameRunning = false
        gameOverDialog.open()
    }

    Dialog {
        height:Screen.height/5
        width:Screen.widtd/10
        id: gameOverDialog
        title: "游戏结束"
        anchors.centerIn: parent
        standardButtons: Dialog.Ok

        Label {
            text: "你的得分: " + score
        }

        onAccepted: stackView.pop()
    }
}
