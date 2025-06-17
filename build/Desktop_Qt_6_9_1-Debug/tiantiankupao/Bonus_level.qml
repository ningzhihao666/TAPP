import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtMultimedia

//奖励关卡

Page{
    id:bonus_level
    height:Screen.height
    width:Screen.width

    //——————————————————————————————————游戏特性——————————————————————————————————
    property int  score: 0                                      //计算得分
    property int  distance:0                                    //计算距离
    property bool gameRunning: false                            //判定游戏是否开始
    property int  sc_x: Screen.width/200                        //屏幕横向划分为200份
    property int  sc_y: Screen.height/100                       //屏幕纵向划分为100份（因为手机横屏）
    property int  speed:sc_x*1                                  //速度
    property int  max_speed:sc_x*4                              //最大速度

    //—————————————————————————————————地面块属性————————————————————————————————————
    property int  groundheight:Screen.height*4/5                //初始化地面高度为屏幕下方1/5
    property int  groundheight_top:Screen.height*3/5            //变化的最高高度
    property int  groundheight_buttom:Screen.height*4/5         //变化的最低高度
    property int  groundheight_next_top:Screen.height*4/5       //下一个地面块的顶部高度
    property int  ground_width:sc_x*30                          //短地面块宽度

    //——————————————————————————————————玩家属性———————————————————————————————————
    property int  player_normal_x:sc_x*30                       //玩家初始x坐标

    property int  player_x:sc_x*30                              //人物x坐标
    property int  player_y:Screen.height*4/5-player_height      //人物y坐标
    property int  player_height:Screen.height/6                 //人物高度
    property int  player_width:Screen.width/12                  //人物宽度
    property int  player_normal_height:Screen.height/6          //人物的初始高度
    property int  player_normal_width:Screen.width/12           //人物的初始宽度

    //_________滑铲__________
    property int  player_slide_height:Screen.height/9.5         //人物滑铲高度
    property int  player_slide_width:Screen.width*0.11          //人物滑铲宽度
    property bool isSliding:false                               //是否滑铲
    property bool need_slide:false                              //是否需要滑铲
    property bool mustSlide:false                               //锁定滑铲状态
    property bool slideButton_press:false                       //滑铲按键是否被按压

    //_________跳跃__________
    property bool is_Dead:false                                 //判断是否死亡
    property bool isJumping:false                               //是否在跳跃
    property bool isDowning:false                               //跳跃下落
    property real jumpVelocity:0                                //跳跃速度
    property real gravity:sc_y*1.4                              //重力加速度
    property int  jump_top:Screen.height*0.25                   //跳跃的最大距离
    property bool need_jump:false                               //用于死亡条件1是否需要跳跃

    property int  nextground_x:1                                //下一个地面块的x坐标
    property int  nextground_top:Screen.height*4/5              //下一个地面块顶面top
    property bool on_ground:true                                //重力引擎判断条件

    //——————————————————————————————————金币属性———————————————————————————————————
    property int  coin_height:Screen.height/20                  //金币的高度
    property int  coin_width:coin_height                        //金币的宽度
    property int  coin_num:0                                    //所得金币数量
    property int  coin_change_jishu:1                           //金币高度变化计数
    property int  coin_change_mutex:1                           //金币变化锁
    property bool begin_coin:true                               //金币变化的开始

    //——————————————————————————————————奖励关卡———————————————————————————————————
    property int  energy_max:100                                //100的满格能量
    property int  current_energy:0                              //当前能量
    property bool goto_bonusLevel:false                         //进入奖励关卡

    signal shuxingChange(int newScore,int newDistance,int newCoinNum)         //原有属性发生改变

    ListModel{ id:activeGrounds }          //地面块容器
    ListModel{ id:back_ground1}            //背景图层1
    ListModel{ id:back_ground2}            //背景图层2
    ListModel{ id:activeCoins }            //金币容器

    Image{
        id:background
        anchors.fill:parent
        source:"qrc:/bonus_level/Images/bonus_level/奖励关卡背景图.jpg"
    }

    Label{
        background: Rectangle{
            color:"transparent"
        }
        id:jiangli_text
        text:"奖励关卡"
        font.pixelSize:100
        color:"black"
        visible:false
        anchors.centerIn: parent
    }

    Timer{
        running:true
        interval:500
        repeat:false
        onTriggered: {
            jiangli_text.visible=true
            end_text.start()
        }
    }

    Timer{
        id:end_text
        running:false
        interval:1000
        repeat:false
        onTriggered: {
            jiangli_text.visible=false
        }
    }

    Timer{
        id:jishiqi
        running:true
        interval:10000
        repeat:false
        onTriggered: {
            bonus_level.shuxingChange(bonus_level.score,
                                      bonus_level.distance,
                                      bonus_level.coin_num)
        }
    }

    Component.onCompleted: {
        var is_initGround=true          //该条件用于初始化时地面的高度不产生变化
        //初始化地面
        for(var i=0;i<10;i++){
            generateGround(i*ground_width,is_initGround)
        }

        //初始化金币
        for(var i=0;i<10;i++){
            generateCoin()
        }
    }

    //更新地面位置
    function generateGround(startX,is_initGround){
        var generate_coin =false               //是否有金币生成
        var newX=startX !==undefined? startX:(activeGrounds.count>0?activeGrounds.get(activeGrounds.count-1).x+activeGrounds.get(activeGrounds.count-1).width:0)

        activeGrounds.append({
        "x":newX,
        "top":groundheight,                   //用于判定地面的顶端
        "width":ground_width,
        "height":Screen.height/3,
        "generate_coin":generate_coin,
        });

        if(Math.random()>0.7){
            back_ground1.append({
            "x":newX,
            "top":groundheight,                   //用于判定地面的顶端
            "width":ground_width,
            "height":Screen.height/3,
            "generate_coin":generate_coin,
            });
        }

        if(Math.random()>0.7){
            back_ground2.append({
            "x":newX,
            "top":groundheight,                   //用于判定地面的顶端
            "width":ground_width,
            "height":Screen.height/3,
            "generate_coin":generate_coin,
            });
        }
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
        var coin_newx=activeCoins.count > 0 ? activeCoins.get(activeCoins.count - 1).x +1.5*coin_width : Screen.width+ sc_x * 1
        var coin_y=groundheight-coin_height

        if(coin_change_jishu===5){
            coin_change_mutex+=1
        }

        if(activeCoins.count > 0 && coin_change_mutex%2==1){
            coin_y=groundheight-coin_change_jishu*coin_height
            coin_change_jishu+=1
            begin_coin=false
        }

        if(coin_change_mutex%2==0){
            coin_y=groundheight-coin_change_jishu*coin_height
            coin_change_jishu-=1
        }

        if(coin_change_jishu===1 && !begin_coin){
            coin_change_mutex+=1
        }

        if(coin_newx>Screen.width*1.5) return

        activeCoins.append({
            "x":coin_newx,
            "y":coin_y,
            "height":coin_height,
            "width":coin_width
        })
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
                coin_num+=1
            }
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
                if(back_ground1.get(i)) back_ground1.setProperty(i,"x",back_ground1.get(i).x-speed)
                if(back_ground2.get(i)) back_ground2.setProperty(i,"x",back_ground2.get(i).x-speed)
            }

            //移除超出屏幕地面段
            while(activeGrounds.count>0&&activeGrounds.get(0).x+activeGrounds.get(0).width<0){
                activeGrounds.remove(0)
            }
            while(back_ground1.count>0&&back_ground1.get(0).x+back_ground1.get(0).width*5<0){
                back_ground1.remove(0)
            }
            while(back_ground2.count>0&&back_ground2.get(0).x+back_ground2.get(0).width*5<0){
                back_ground2.remove(0)
            }


            var ground=get_CurrentGround()

            //——————————————————————————————主逻辑2：金币逻辑————————————————————————
            //生成金币
            generateCoin()

            //金币移动
            for(var j=0;j<activeCoins.count;j++){
                activeCoins.setProperty(j,"x",activeCoins.get(j).x-speed)
            }

            //移除超出屏幕的金币
            while(activeCoins.count>0 && activeCoins.get(0).x+coin_width<0)
                activeCoins.remove(0)

            //——————————————————————————————主逻辑3：重力引擎————————————————————————
            //跳跃逻辑处理
            if(isJumping){
                var jumpVelocity_temp=jumpVelocity
                jumpVelocity_temp+=gravity
                jump_top-=jumpVelocity_temp
                player_y-=jumpVelocity_temp
                if(jump_top<=0){
                    isJumping=false
                    isDowning=true                  //设置此时开始下落
                    jump_top=Screen.height*0.25     //回归跳跃高度
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
                    player_y=ground.top-player_height
                    isDowning=false             //下落停止
                }
            }
        }
    }

    //可视化
    Item{
        //地面块
        Repeater{
            model:activeGrounds
            delegate:Rectangle{
                x:model.x
                y:model.top
                color:"transparent"
                width:model.width
                height:model.height
                //border.width:1

                Image{
                    source:"qrc:/bonus_level/Images/bonus_level/地面图层1.png"
                    anchors.fill:parent
                    fillMode: Image.PreserveAspectCrop
                }
            }
        }
        //背景图层1
        Repeater{
            model:back_ground1
            delegate:Rectangle{
                x:model.x
                y:model.top*0.9
                color:"transparent"
                width:model.width*1.6
                height:model.height*0.4
                //border.width:1

                Image{
                    source:"qrc:/bonus_level/Images/bonus_level/地面图层2.png"
                    anchors.fill:parent
                    //fillMode: Image.PreserveAspectCrop
                }
            }
        }
        //背景图层2
        Repeater{
            model:back_ground2
            delegate:Rectangle{
                x:model.x
                y:model.top*1.1
                color:"transparent"
                width:model.width*2
                height:model.height*0.5
                //border.width:1

                Image{
                    source:"qrc:/bonus_level/Images/bonus_level/地面图层4.png"
                    anchors.fill:parent
                    fillMode: Image.PreserveAspectCrop
                }
            }
        }

        //金币
        Repeater{
            model:activeCoins
            delegate:Rectangle{
                id:coin_sg
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
                //转动动画
                RotationAnimator{
                    target:coin_sg
                    from:0
                    to:360
                    duration:1000
                    loops:Animation.Infinite
                    running:true
                }
            }
        }
    }

    // 玩家角色
    Player {
        id: player
        x: bonus_level.player_x
        y: bonus_level.player_y
        height:bonus_level.player_height
        width:bonus_level.player_width
        isSliding:bonus_level.isSliding
        isJumping:bonus_level.isJumping
        isDowning:bonus_level.isDowning
        gameRunning:bonus_level.gameRunning
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
                bonus_level.slideButton_press=true
                begin_slide()
            }
            onReleased:{
                bonus_level.slideButton_press=false
                end_slide()
            }
        }
    }

    //游戏控制面板
    GameControlPanel {
        score: bonus_level.score
        distance:bonus_level.distance
        gameRunning: bonus_level.gameRunning
        onPauseGame: gamePauseDialog.open()
    }

    function gameOver() {
        is_Dead=true
        gameRunning = false
        gameOverDialog.open()
    }

    //游戏暂停弹窗
    Dialog {
        id: gamePauseDialog
        height:Screen.height*3/5
        width:Screen.width*3/5
        title: "游戏暂停"
        modal:true
        dim:true                            //添加半透明黑色遮罩
        closePolicy:Popup.NoAutoClose       //禁止点击外部关闭
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
                        "coins_num":coin_num,
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

    //能量条
    Rectangle{
        id:energy_bar
        height:Screen.height*0.1
        width:Screen.width*0.3
        border.width:1
        radius:Screen.height*0.5

        anchors{
            bottom:parent.bottom
            bottomMargin:Screen.height*0.05
            horizontalCenter: parent.horizontalCenter
        }

        //能量度
        Rectangle{
            id:energy_du
            height:parent.height
            width:0
            color:"yellow"
            border.width:1
            radius:Screen.height*0.5
        }

        Label{
            anchors.centerIn:parent
            text:"当前能量: "+current_energy
            color:"black"
        }
    }
}
