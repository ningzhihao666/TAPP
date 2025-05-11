import QtQuick
import QtQuick.Controls
import QtQuick.Window

//游戏屏幕页面

Page {
    id: gameScreen
    width: Screen.width
    height: Screen.height

    //游戏特性
    property int  score: 0                                      //计算得分
    property int  distance:0                                    //计算距离
    property int  coins_num:0                                   //金币数量
    property bool gameRunning: false                            //判定游戏是否开始
    property int  sc_x: Screen.width/200                        //屏幕横向划分为200份
    property int  sc_y: Screen.height/100                       //屏幕纵向划分为100份（因为手机横屏）
    property int  speed:sc_x*1                                  //速度
    property int  max_speed:sc_x*4                              //最大速度

    //地面块属性:
    property int  groundheight:Screen.height*4/5                //初始化地面高度为屏幕下方1/5
    property int  groundheight_top:Screen.height*3/5            //变化的最高高度
    property int  groundheight_buttom:Screen.height*4/5         //变化的最低高度
    property int  groundheight_next_top:Screen.height*4/5       //下一个地面块的顶部高度

    //玩家属性
    property int  player_x:sc_x*10                              //人物x坐标
    property int  player_y:Screen.height*4/5-player_height      //人物y坐标
    property int  player_height:Screen.height/6                 //人物高度
    property int  player_width:Screen.width/12                  //人物宽度
    property int  player_normal_height:Screen.height/6          //人物的初始高度
    property int  player_normal_width:Screen.width/12           //人物的初始宽度
    property int  player_slide_height:Screen.height/9.5         //人物滑铲高度
    property int  player_slide_width:Screen.width/8             //人物滑铲宽度

    property bool is_Dead:false                                 //判断是否死亡
    property bool isJumping:false                               //是否在跳跃
    property bool isDowning:false                               //跳跃下落
    property bool isSliding:false                               //是否滑铲
    property real jumpVelocity:0                                //跳跃速度
    property real gravity:sc_y*1.5                              //重力加速度
    property int  jump_top:Screen.height/5                      //跳跃的最大距离
    property int  nextground_x:1                                //下一个地面块的x坐标
    property int  nextground_top:Screen.height*4/5              //下一个地面块顶面top
    property bool need_jump:false                               //用于死亡条件1是否需要跳跃
    property bool on_ground:true                                //重力引擎判断条件

    //金币属性
    property int  coin_height:Screen.height/20                  //金币的高度
    property int  coin_width:coin_height                        //金币的宽度

    // 游戏背景
    Image {
        source: "qrc:/BackGround/Images/BackGround/beijing1.png"
        anchors.fill: parent
    }

    ListModel{ id:activeGrounds }          //地面块容器
    ListModel{ id:activeCoins }            //金币容器


    Component.onCompleted: {
        var is_initGround=true          //该条件用于初始化时地面的高度不产生变化
        //初始化地面
        for(var i=0;i<20;i++){
            generateGround(i*sc_x*20,is_initGround)
        }

        //初始化金币
        for(var i=0;i<10;i++){
            generateCoin()
        }
    }

    //更新地面位置
    function generateGround(startX,is_initGround){
        var hasGap=Math.random()>0.9           //设立10%的概率为空缺
        var hasChange=Math.random()>0.8        //设立20%的概率为高度变化
        var change_height=Math.random()>0.5    //设立50%的概率变高，为了让变化高度都要在10以上
        var generate_coin =false               //是否有金币生成

        if(!is_initGround){
            if(!hasGap){
                if(hasChange){
                    if(groundheight<=groundheight_top)
                        groundheight+=Math.random()*sc_y*5+sc_y*1
                    else if(groundheight>=groundheight_buttom)
                        groundheight-=Math.random()*sc_y*5+sc_y*1
                    else{
                        if(change_height){
                            groundheight+=Math.random()*sc_y*5+sc_y*1
                        }
                        else{
                            groundheight-=Math.random()*sc_y*5+sc_y*1
                        }
                    }
                }
            }
            else{
                groundheight=Screen.height
            }
        }

        var newX=startX !==undefined? startX:(activeGrounds.count>0?activeGrounds.get(activeGrounds.count-1).x+sc_x*20:0)

        activeGrounds.append({
        "x":newX,
        "width":sc_x*20,
        "height":Screen.height/3,
        "top":groundheight,          //用于判定地面的顶端
        "hasGap":hasGap,
        "generate_coin":generate_coin
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
        }
    }

    //滑铲开始
    function begin_slide(){
        if(!isJumping && !isSliding){
            isSliding=true
            player_height=player_slide_height
            player_width=player_slide_width
        }
    }

    function end_slide(){
        if(!isJumping && isSliding){
            isSliding=false
            player_height=player_normal_height
            player_width=player_normal_width
        }
    }

    //金币生成函数
    function generateCoin()
    {
        var last_ground=activeGrounds.get(activeGrounds.count-1)
        var is_generate=Math.random()<0.25      //0.25的概率生成金币
        if(!last_ground.hasGap && !last_ground.generate_coin && is_generate)
        {
            var startX=activeCoins.count > 0 ? activeCoins.get(activeCoins.count - 1).x + 2 * coin_width : last_ground.x + sc_x * 4
            var coin_newx = startX
            if(coin_newx>last_ground.x+sc_x*16) return
            var coin_y=last_ground.top-coin_height*1.5
            activeGrounds.get(activeGrounds.count-1).generate_coin=true

            activeCoins.append({
                "x":coin_newx,
                "y":coin_y,
                "height":coin_height,
                "width":coin_width
            })
        }
    }

    //金币碰撞函数
    function collides_coin(obj1,obj2)
    {
        if(obj1 && obj2){  //当两个对象都存在时进行判定
            //console.log("进入判定")
            var res= (obj1.x<obj2.x+obj2.width &&
                      obj1.x+obj1.width>obj2.x &&
                      obj1.y*0.95 < obj2.y &&
                      (obj1.y+obj1.height)*1.05>obj2.y)
            return res
        }
        else
        {
            if(obj1) console.log("obj1存在")
            if(obj2) console.log("obj2存在")
            return 0
        }
    }

    //金币拾取及加分
    function check_coin()
    {
        for(var i=0;i<activeCoins.count;i++)
        {
            var coin=activeCoins.get(i)
            if(collides_coin(player,coin))
            {
                activeCoins.remove(i)
                score+=10                              //每个金币都能让人物
            }
        }
    }

    //速度计时器
    Timer{
        interval:20000     //20s速度+1
        running:gameRunning&&!is_Dead
        repeat:true
        onTriggered:{
            if(speed!==max_speed)
                speed+=1
        }
    }

    //游戏主循环
    Timer{
        interval:16                               //60fps
        running:gameRunning&&!is_Dead
        repeat:true
        onTriggered:{
            distance+=4;               //距离计算
            check_coin()               //金币碰撞检测

            //——————————————————————————————主逻辑1：地面逻辑————————————————————————
            //生成新地面段
            if(activeGrounds.count===0||activeGrounds.get(activeGrounds.count-1).x<2*Screen.width)
                generateGround()

            //移动地面
            for(var i=0;i<activeGrounds.count;i++){
                activeGrounds.setProperty(i,"x",activeGrounds.get(i).x-speed)
            }

            //移除超出屏幕地面段
            while(activeGrounds.count>0&&activeGrounds.get(0).x+sc_x*20<0)
                activeGrounds.remove(0)

            var ground=get_CurrentGround()

            //——————————————————————————————主逻辑2：金币逻辑————————————————————————
            //生成金币
            if(activeCoins.count===0 || activeCoins.get(activeCoins.count-1).x<Screen.width)
                generateCoin()

            //金币移动
            for(var j=0;j<activeCoins.count;j++){
                activeCoins.setProperty(j,"x",activeCoins.get(j).x-speed)
            }

            //移除超出屏幕的金币
            while(activeCoins.count>0 && activeCoins.get(0).x+coin_width<0)
                activeCoins.remove(0)

            //——————————————————————————————主逻辑3：重力引擎————————————————————————

            //死亡条件1:被地面顶到左边屏幕外
            if((nextground_x-player_x-player_width)<0.1){
                if(player_y+player_height>nextground_top){
                    need_jump=true
                    player_x-=speed
                    if(player_x<=0){      //死亡
                        gameOver()
                        return   }
                }
                else{
                    need_jump=false
                }
            }
            //恢复x位置
            if(!need_jump && player_x<sc_x*10){   player_x+=speed   }

            //跳跃逻辑处理
            if(isJumping){
                var jumpVelocity_temp=jumpVelocity
                jumpVelocity_temp+=gravity
                jump_top-=jumpVelocity_temp
                player_y-=jumpVelocity_temp
                if(jump_top<=0){
                    isJumping=false
                    isDowning=true              //设置此时开始下落
                    jump_top=Screen.height/5
                }
            }

            //重力引擎
            if(player_y+player_height<ground.top){
                on_ground=false
            }
            if(!isJumping && !on_ground){
                var jumpVelocity_temp=jumpVelocity
                jumpVelocity_temp+=gravity
                player_y+=jumpVelocity_temp
                if(player_y+player_height>=ground.top){
                    //死亡条件2
                    if(player_y+player_height>=Screen.height){
                        gameOver()
                        return    }
                    player_y=ground.top-player_height
                    isDowning=false             //下落停止
                }
            }
        }
    }

    //可视化
    Item{
        Repeater{                        //地面块
            model:activeGrounds
            delegate:Rectangle{
                x:model.x
                y:model.top
                color:"transparent"
                width:model.width
                height:model.height

                Image{
                    height:parent.height
                    width:parent.width
                    source:"qrc:/BackGround/Images/BackGround/地面块1.png"
                    anchors{
                        top:parent.top
                        left:parent.left
                    }

                    fillMode: Image.PreserveAspectCrop
                }
            }
        }

        Repeater{                        //金币
            model:activeCoins
            delegate:Rectangle{
                x:model.x
                y:model.y
                color:"transparent"
                width:model.width
                height:model.height

                Image{
                    source:"qrc:/BackGround/Images/BackGround/金币.png"
                    anchors.fill:parent
                    fillMode: Image.PreserveAspectCrop
                }
            }
        }
    }

    // 玩家角色
    Player {
        id: player
        x: gameScreen.player_x
        y: gameScreen.player_y
        height:gameScreen.player_height
        width:gameScreen.player_width
        isSliding:gameScreen.isSliding
        isJumping:gameScreen.isJumping
        isDowning:gameScreen.isDowning
        gameRunning:gameScreen.gameRunning
    }

    // 跳跃和滑铲按钮
    Rectangle{
        height:Screen.height*0.2;   width:height;   radius:width/2
        border.width:1;  clip:true;    visible: gameRunning
        color:"transparent"
        anchors{ bottom:parent.bottom;  bottomMargin: 5*sc_y;
            left:parent.left;   leftMargin: 10}
        Label{text:"跳跃"; color:"black";  anchors.centerIn:parent}
        Button{
            anchors.fill:parent
            background: Rectangle{ color:"transparent"; radius:parent.radius }
            Image{
                height:parent.height;  width:parent.width
                source:"qrc:/player/Images/player/跳跃.png"
                anchors.centerIn:parent;   fillMode:Image.PreserveAspectCrop
            }

            onClicked:jump()
        }
    }

    Rectangle{
        height:Screen.height*0.2;   width:height;   radius:width/2
        border.width:1;  clip:true;    visible: gameRunning
        color:"transparent"
        anchors{ bottom:parent.bottom;  bottomMargin: 5*sc_y;
            right:parent.right;   rightMargin: 10}
        Label{text:"滑铲"; color:"black";  anchors.centerIn:parent}

        Image{
            anchors.fill:parent
            source:"qrc:/player/Images/player/滑铲.png"
            anchors.centerIn:parent;   fillMode:Image.PreserveAspectCrop
        }

        MouseArea{
            anchors.fill:parent
            onPressed: {
                begin_slide()
            }
            onReleased:{
                end_slide()
            }
        }
    }

    //游戏控制面板
    GameControlPanel {
        score: gameScreen.score
        distance:gameScreen.distance
        gameRunning: gameScreen.gameRunning
        onStartGame: gameScreen.gameRunning = true
        onPauseGame: gameScreen.gameRunning = false
    }

    function gameOver() {
        is_Dead=true
        gameRunning = false
        gameOverDialog.open()
    }

    Dialog {
        id: gameOverDialog
        height:Screen.height*3/5
        width:Screen.width*3/5
        title: "游戏结束"
        modal:true

        anchors.centerIn: parent

        Rectangle{
            height:parent.height*0.3
            width:parent.width*0.3
            border.width:1
            radius:5
            anchors{
                bottom:parent.bottom
                bottomMargin:parent.height*0.1
                horizontalCenter: parent.horizontalCenter
            }
            Button{
                background: Rectangle{color:"transparent"}
                anchors.fill:parent
                Label{text:"结算"; color:"black"; anchors.centerIn: parent}
                onClicked: {
                    stackView.replace("Page_jiesuan.qml",{
                        "distance":distance/16,
                        "score":score,
                        "coins_num":coins_num,
                    })
                    gameOverDialog.close()
                }
            }
        }

        Label {
            text: "你的得分: " + score
            color:"black"
            anchors.centerIn: parent
        }
    }
}
