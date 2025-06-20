import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtMultimedia

//游戏屏幕页面

Page {
    id: gameScreen
    width: Screen.width
    height: Screen.height

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
    property int  longGround_width:sc_x*60                      //长地面块宽度
    property bool no_change_ground:true                         //该地面块无变化
    property bool ground_hasBigGap:false                        //具有长空缺
    property var  tanhuang_ground:({})                          //具有弹簧的地面块

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

    //——————————————————————————————————奖励关卡———————————————————————————————————
    property int  energy_max:100                                //100的满格能量
    property int  current_energy:0                              //当前能量
    property bool goto_bonusLevel:false                         //进入奖励关卡
    property string background_original_img:"qrc:/BackGround/Images/BackGround/游戏主页面背景.jpg"       //原始背景图
    property string background_bonusLevel_img:"qrc:/bonus_level/Images/bonus_level/奖励关卡背景图.jpg"     //奖励关卡背景图

    //—————————————————————————————————道具属性————————————————————————————————————
    property real attractPower: 1.0                             //吸引力强度系数
    property bool isAttracting: false                           //吸引力激活状态
    property bool doublePointsActive: false                     //双倍积分激活状态
    property int  baseScoreRate:20                              //基础得分系数

    property bool isEnlarged: false                             //是否变大状态标志
    property int  player_enlarge_slide_height:(Screen.height/9.5)*1.5           //人物初始滑铲高度
    property int  player_enlarge_slide_width:(Screen.width/8) *1.5            //人物初始滑铲宽度
    property int  doublePointsRemaining: 0

    property bool isShielded: false                             //护盾激活状态标志
    property int  shieldRemaining: 0                            //护盾剩余时间
    property var shieldVisual: null                             //正确定义shieldVisual 为游戏屏幕的属性
    //—————————————————————————————————网络属性————————————————————————————————————
    property bool isMultiplayer: false
    property bool isLocalPlayer: true
    property var gameState: ({})
    // 新增对战相关属性
    property var opponentState: ({})  // 对手状态
    property var lo
    property int randomSeed: 0

    // 游戏背景
    Image {
        id:background_img
        source: background_original_img
        anchors.fill: parent
    }

    MediaPlayer {
        audioOutput: AudioOutput { volume:1 }
        source: "qrc:/musics/musics/两难.mp3"
        loops:MediaPlayer.Infinite
        Component.onCompleted: { play() }
    }

    ListModel{ id:activeGrounds }          //地面块容器
    ListModel{ id:activeCoins }            //金币容器

    //资源加载器
    Loader{
        id:loader
        anchors.fill:parent
        z:100
    }

    //奖励关卡
    Component{
        id:bonus_level
        Bonus_level{
            score:gameScreen.score
            distance: gameScreen.distance
            speed:gameScreen.speed
            coin_num:gameScreen.coin_num
            gameRunning:gameScreen.goto_bonusLevel
            onShuxingChange:{
                gameScreen.score=newScore
                gameScreen.distance=newDistance
                gameScreen.coin_num=newCoinNum
            }
        }
    }

    Component.onCompleted: {
        var is_initGround=true          //该条件用于初始化时地面的高度不产生变化
        //初始化地面y
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
        var hasGap=Math.random()>0.75           //设立25%的概率为空缺
        var hasChange=Math.random()>0.9         //设立10%的概率为高度变化
        var obstacle=Math.random()>0.9          //设置10%概率生成障碍物
        var change_height=Math.random()>0.5     //设立50%的概率变高，为了让变化高度都要在10以上
        var generate_coin =false                //是否有金币生成
        var keep_ground=0                       //用于标记障碍物后面地面块变化
        var is_longGround=Math.random()>0.5     //50%概率为长地面块
        var current_width=ground_width

        //标记生成箱子或者障碍物
        var spawn_obstacle=false                //生成箱子
        var spawn_daoju=false                   //生成道具箱子

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
                if(is_longGround) current_width=longGround_width
                else current_width=ground_width
            }
            else{
                groundheight=Screen.height
            }
        }

        if(Math.random()>0.5) spawn_obstacle=true
        else spawn_daoju=true

        var newX=startX !==undefined? startX:(activeGrounds.count>0?activeGrounds.get(activeGrounds.count-1).x+activeGrounds.get(activeGrounds.count-1).width:0)

        activeGrounds.append({
        "x":newX,
        "width":current_width,
        "height":Screen.height/3,
        "top":groundheight,                    //用于判定地面的顶端
        "hasGap":hasGap,
        "generate_coin":generate_coin,
        "is_longGround":is_longGround,         //是否为长地面块
        "spawn_obstacle":spawn_obstacle,       //允许生成箱子
        "spawn_daoju":spawn_daoju              //允许生成道具
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
              if(isEnlarged){
                  player_height=player_enlarge_slide_height
                  player_width=player_enlarge_slide_width
            }
            else{
               player_height=player_slide_height
               player_width=player_slide_width
              }
        }
    }

    function end_slide(){
        if(!isJumping && isSliding && !mustSlide){
            isSliding=false
            if(isEnlarged){
                player_height=player_normal_height*1.5
                player_width=player_normal_width*1.5
            }
            else{
                player_height=player_normal_height
                player_width=player_normal_width
            }
        }
    }

    //金币生成函数
    function generateCoin()
    {
        var last_ground=activeGrounds.get(activeGrounds.count-1)
        if(!last_ground.hasGap && !last_ground.generate_coin)
        {
            var startX=activeCoins.count > 0 ? activeCoins.get(activeCoins.count - 1).x + 2 * coin_width : last_ground.x + sc_x * 1
            var coin_newx = startX
            if(coin_newx>last_ground.x+last_ground.width) return

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
                coin_num+=1
                add_energy()                           //增加能量条
            }
        }
    }

    //检测连续空洞
    function check_big_gap()
    {
        for(var i=1;i<activeGrounds.count-1; i++){
            if(activeGrounds.get(i-1).hasGap===false){
                if(activeGrounds.get(i).hasGap===true){
                    if(activeGrounds.get(i+1).hasGap===true){
                        ground_hasBigGap=true
                        tanhuang_ground=activeGrounds.get(i-1)
                    }
                }
            }
        }
    }

    //速度计时器
    Timer{
        interval:20000     //20s速度+1
        running:gameRunning&&!is_Dead
        repeat:true
        onTriggered:{
            if(speed!==max_speed){
                speed+=1
                gravity+=sc_y*0.1
            }
        }
    }

    //连续空缺检测
    Timer{
        interval:1000     //1s检测一次
        running:gameRunning&&!is_Dead
        repeat:true
        onTriggered:{
            check_big_gap()
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
            while(activeGrounds.count>0&&activeGrounds.get(0).x+activeGrounds.get(0).width<0)
                activeGrounds.remove(0)

            var ground=get_CurrentGround()

            //——————————————————————————————主逻辑2：金币逻辑————————————————————————
            //生成金币
            if(activeCoins.count===0 || activeCoins.get(activeCoins.count-1).x<2*Screen.width)
                generateCoin()

            //金币移动
            for(var j=0;j<activeCoins.count;j++){
                activeCoins.setProperty(j,"x",activeCoins.get(j).x-speed)
            }

            //移除超出屏幕的金币
            while(activeCoins.count>0 && activeCoins.get(0).x+coin_width<0)
                activeCoins.remove(0)

            //——————————————————————————————主逻辑3：重力引擎————————————————————————

            //被地面顶到左边屏幕外
            if((nextground_x-player_x-player_width)<0.1){
                if(player_y+player_height>nextground_top){
                    need_jump=true
                    player_x-=speed
                }
                else{
                    need_jump=false
                }
            }

            //恢复x位置
            if(!need_jump && player_x<player_normal_x && !need_slide){
                player_x+=speed*0.5   }

            //死亡处理
            if(player_x+player_width<=0){
                gameOver()
                return   }

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
        //地面块
        Repeater{
            model:activeGrounds
            delegate:Rectangle{
                x:model.x
                y:model.top
                color:"transparent"
                width:model.width
                height:model.height
                border.width:1

                Image{
                    source:"qrc:/BackGround/Images/BackGround/地面块1.png"
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
                gameScreen.slideButton_press=true
                begin_slide()
            }
            onReleased:{
                gameScreen.slideButton_press=false
                end_slide()
            }
        }
    }

    //游戏控制面板
    GameControlPanel {
        score: gameScreen.score
        distance:gameScreen.distance
        gameRunning: gameScreen.gameRunning
        onPauseGame: {
            gameScreen.gameRunning=false
            gamePauseDialog.open()
        }
    }

    function gameOver() {
        is_Dead=true
        gameRunning = false
        gameOverDialog.open()
    }

    //弹簧计时器
    Timer{
        id:tanhuang_jishi
        interval:1000
        running:false
        repeat:false
        onTriggered:{
            gameScreen.speed-=1
            gameScreen.jump_top/=1.5
            console.log("计时器被触发")
        }
    }

    //障碍物生成
    ObstacleGenerator{
        id:obstacle_generator

        //传入控制属性
        gameRunning:gameScreen.gameRunning
        activeGrounds:activeGrounds
        speed:gameScreen.speed
        ground_hasBigGap:gameScreen.ground_hasBigGap
        tanhuang_ground:gameScreen.tanhuang_ground
        goto_bonusLevel:gameScreen.goto_bonusLevel

        //传入人物属性
        player_normal_x:gameScreen.player_normal_x

        player_y:gameScreen.player_y
        player_x:gameScreen.player_x
        player_height:gameScreen.player_height
        player_width:gameScreen.player_width
        player_slide_height: gameScreen.player_slide_height
        isJumping:gameScreen.isJumping

        //槽函数接受信号
        onMovePlayer:     {  gameScreen.player_x+=change_x;    }
        onMustSlide:      {   gameScreen.need_slide=true       }
        onMustSlideKeep:  {    begin_slide()                   }
        onMustSlideEnd:{
            gameScreen.need_slide=false
            if(!gameScreen.slideButton_press) end_slide()
        }
        onPlayerDead:     {       gameOver()                   }
        onTanhuangJump:  {
            tanhuang_jishi.stop()
            gameScreen.speed+=1
            gameScreen.jump_top*=1.5
            gameScreen.jump()
            tanhuang_jishi.start()
        }
        onReadyTanhuang:  {  gameScreen.ground_hasBigGap=false}
        onAddEnergy:      {  gameScreen.add_energy()          }
    }

    //——————————————————————————————道具模块——————————————————————————————
    DaojuGenerator {
        id: daojugenerator

        speed:gameScreen.speed
        running: gameScreen.gameRunning
        parent: gameScreen
        anchors.fill: parent
        activeGrounds: activeGrounds
    }

    DaojuDetector {
        id: daojuDetector
        player: player
        daojus: daojugenerator.daojus  // 绑定到 DaojuGenerator 的 ListModel
        onDaojuCollected: gameScreen.activateDoublePoints(5000)
        onAttractActivated: gameScreen.handleAttractEffect(5000)
        onEnlargeActivated: gameScreen.activateEnlargeEffect(5000)
        onShieldActivated:gameScreen.activateShieldEffect(5000)
        onObstacleHit: gameOver()
    }

    // 新增双倍积分计时器
    Timer {
        id: doublePointsTimer
        interval: 1000  // 每秒更新
        repeat: true
        onTriggered: {
            doublePointsRemaining = Math.max(0, doublePointsRemaining - 1000)
            if (doublePointsRemaining <= 0) {
                doublePointsActive = false
            }
        }
    }
    function activateDoublePoints(duration) {
        // 如果已有双倍效果，时间累加但不超过10秒
        const maxDuration = 10000
        doublePointsRemaining = Math.min(maxDuration, doublePointsRemaining + duration)

        // 保证计时器运行
        if (!doublePointsTimer.running) {
            doublePointsTimer.start()
        }

        // 强制激活状态
        doublePointsActive = true
    }

    function addScore(points) {
        score += doublePointsActive ? points * 2 : points // 实际翻倍逻辑应在此类函数中实现[7](@ref)
    }

    //双倍积分提示动画
    Label {
        id: doublePointsIndicator
        visible: doublePointsActive
        text: "双倍积分！剩余: " + (doublePointsRemaining/1000) + "秒"
        color: "#FFD700"  // 金色
        font.bold: true
        font.pixelSize: 24
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: 20
        }
        // 添加闪烁效果
        SequentialAnimation on opacity {
            running: doublePointsActive
            loops: Animation.Infinite
            NumberAnimation { to: 0.5; duration: 500 }
            NumberAnimation { to: 1.0; duration: 500 }
        }
    }

    //吸引力激活特效
    Rectangle {
        visible: isAttracting
        width: Screen.width*0.1
        height: width
        radius: width/2
        color: "#00FF0022"
        border.color: "#00FF00"
        border.width: 3
        anchors.centerIn: player

        // 脉冲动画
        SequentialAnimation on scale {
            running: isAttracting
            loops: Animation.Infinite
            NumberAnimation { to: 1.5; duration: 1000; easing.type: Easing.OutQuad }
            NumberAnimation { to: 1.0; duration: 1000; easing.type: Easing.InQuad }
        }
    }

    //磁铁处理器
    function handleAttractEffect(duration) {
        // 1. 启动吸引力计时器
        isAttracting = true
        attractPower = 1.0
        //启动持续时间和衰减效果
        attractTimer.interval = duration
        attractTimer.start()
        // 启动金币移动
        attractMovementTimer.start()
        //吸引力衰减动画
        attractDecayAnimation.start()
        // 在吸引力激活时播放音效
        //attractSound.play()
    }

    //磁铁计时器
    Timer {
        id: attractTimer
        onTriggered: {
            isAttracting = false
            console.log("吸引力效果结束")
        }
    }

    // 金币移动控制
    Timer {
        id: attractMovementTimer
        interval: 16
        running: isAttracting
        repeat: true
        onTriggered:attractCoins()
    }

    //磁体处理函数
    function attractCoins() {
        if (!isAttracting || activeCoins.count === 0) return

        // 使用玩家中心点坐标
        const playerCenter = Qt.point(
            player.x + player.width/2,
            player.y + player.height/2
        )

        // 优化遍历方式（从后往前遍历）
        for (let i = activeCoins.count - 1; i >= 0; i--) {
               const coin = activeCoins.get(i)
               if (!coin) continue

        // 计算相对位置（考虑吸引力强度系数）
        const dx = (playerCenter.x - (coin.x + coin.width/2)) * attractPower
        const dy = (playerCenter.y - (coin.y + coin.height/2)) * attractPower
        // 动态调整移动速度（距离越近速度越快）
        const distance = Math.sqrt(dx*dx + dy*dy)
        const speedFactor = Math.min(1, 150/(distance + 30))

        // 更新位置（增加边界判断gameScreen）
        coin.x = Math.max(0, coin.x + dx * 0.25 * speedFactor)
         coin.y = Math.max(0, coin.y + dy * 0.25 * speedFactor)
        }
    }

    // 新增吸引力衰减动画
    SequentialAnimation {
        id: attractDecayAnimation
        alwaysRunToEnd: true

        NumberAnimation {
            target: gameScreen
            property: "attractPower"
            from: 1.0
            to: 0.2
            duration: attractTimer.interval
            easing.type: Easing.InQuad
        }

        onFinished: {
            isAttracting = false

        }
    }

    //磁铁动画
    Item {
        visible: gameScreen.isAttracting
        anchors.centerIn: player

        // 引力场波纹
        Repeater {
            model: 3
            delegate: Rectangle {
                width: 100 * index
                height: width
                radius: width/2
                color: "transparent"
                border.color: Qt.rgba(0,1,0, 0.5 - index*0.15)
                opacity: 0.7

                NumberAnimation on width {
                    from: 50
                    to: 300
                    duration: 1500
                    loops: Animation.Infinite
                    easing.type: Easing.OutQuad
                }

                NumberAnimation on opacity {
                    from: 0.7
                    to: 0
                    duration: 1500
                    loops: Animation.Infinite
                    easing.type: Easing.InQuad
                }
            }
        }
    }

    //变大处理函数
    function activateEnlargeEffect(duration) {
        // 如果已经处于变大状态，则直接返回
        if (isEnlarged) {
            console.log("玩家已处于变大状态，忽略本次触发")
            return;
        }

        isEnlarged = true  // 标记为变大状态

        // 启动放大动画
        enlargeAnim.start()

        // 设置还原定时器
        enlargeRestoreTimer.interval = duration-500
        enlargeRestoreTimer.start()
    }

    //变大动画
    ParallelAnimation {
        id: enlargeAnim
        running: false
        NumberAnimation {
            target: player
            property: "width"
            from: gameScreen.player_width
            to: gameScreen.player_width * 1.5
            duration: 50
            easing.type: Easing.OutBack
        }
        NumberAnimation {
            target: player
            property: "height"
            from: gameScreen.player_height
            to: gameScreen.player_height * 1.5
            duration: 50
            easing.type: Easing.OutBack
        }
        onStopped: {
            gameScreen.player_width = gameScreen.player_normal_width * 1.5;
            gameScreen.player_height = gameScreen.player_normal_height * 1.5;
            console.log(player.x,player.y,player.height,player.width)
            if(gameScreen.isSliding){
                gameScreen.player_width = gameScreen.player_enlarge_slide_width;
                gameScreen.player_height = gameScreen.player_enlarge_slide_height;
            }

            var ground = get_CurrentGround();
        }
    }

    //变大计时器
    Timer {
        id: enlargeRestoreTimer
        onTriggered: {
            console.log("开始恢复，已等待:", interval, "ms")
            // 先停止可能正在进行的放大动画
            if(enlargeAnim.running) {
                enlargeAnim.stop()
                gameScreen.player_width = gameScreen.player_width * 1.5;
                gameScreen.player_height = gameScreen.player_height * 1.5;
            }
            shrinkAnim.start()
        }
    }

    //缩小动画
    ParallelAnimation {
        id: shrinkAnim
        NumberAnimation {
            target: gameScreen
            property: "player_width"
            to: gameScreen.player_normal_width
            duration: 200
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            target: gameScreen
            property: "player_height"
            to: gameScreen.player_normal_height
            duration: 200
            easing.type: Easing.InOutQuad
        }
        onStopped: {

            if(gameScreen.isSliding){
                gameScreen.player_width = gameScreen.player_slide_width;
                gameScreen.player_height = gameScreen.player_slide_height;
            }
            else{
                gameScreen.player_width = gameScreen.player_normal_width;
                gameScreen.player_height = gameScreen.player_normal_height;
            }

            var ground = get_CurrentGround();
            //player.y = ground.top - gameScreen.player_height;  // 更新 y 坐标
            isEnlarged = false;
        }
    }


    // 护盾效果视觉表现
    Rectangle {
        id: shieldEffect
        visible: gameScreen.isShielded
        width: Screen.width * 0.15
        height: width
        radius: width / 2
        color: "#00BFFF22"  // 护盾颜色，带有透明度
        border.color: "#00BFFF"  // 护盾边框颜色（亮蓝色）
        border.width: 3
        anchors.centerIn: player

        // 脉冲动画
        SequentialAnimation on scale {
            running: gameScreen.isShielded
            loops: Animation.Infinite
            NumberAnimation { to: 1.3; duration: 1000; easing.type: Easing.OutQuad }
            NumberAnimation { to: 1.0; duration: 1000; easing.type: Easing.InQuad }
        }
    }

    // 函数：激活护盾效果
    function activateShieldEffect(duration) {
        // 启动护盾计时器
        isShielded = true
        shieldTimer.interval = duration
        shieldTimer.start()

    }

    // 护盾计时器
    Timer {
        id: shieldTimer
        onTriggered: {
            gameScreen.isShielded = false
            console.log("护盾效果结束")
        }
    }


    //游戏结束弹窗
    Dialog {
        id: gameOverDialog
        height:Screen.height*3/5;   width:Screen.width*3/5
        title: "游戏结束"
        modal:true
        closePolicy:Popup.NoAutoClose       //禁止点击外部关闭
        Image{
            source:"qrc:/BackGround/Images/BackGround/暂停面板背景.jpg"
            anchors.fill:parent
        }

        anchors.centerIn: parent

        Rectangle{
            height:parent.height*0.3;  width:parent.width*0.3;  color:"lightgreen"
            border.width:1;   radius:parent.height*0.15
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


    //游戏暂停弹窗
    Dialog {
    id: gamePauseDialog
    height:Screen.height*3/5
    width:Screen.width*3/5
    modal:true
    closePolicy:Popup.NoAutoClose       //禁止点击外部关闭
    anchors.centerIn: parent

    Image{
        source:"qrc:/BackGround/Images/BackGround/暂停面板背景.jpg"
        anchors.fill:parent
    }

    Rectangle{
        id:jixu;   height:parent.height*0.2;   width:parent.width*0.5;    radius:parent.height*0.1;
        color:"lightgreen"
        Button{
            background: Rectangle{color:"transparent"; }
            Label{ text:"继续游戏";  color:"black";  anchors.centerIn:parent}
            onClicked: { gamePauseDialog.close(); gameScreen.gameRunning=true }
            anchors.fill:parent
        }
        anchors{
            top:parent.top;    topMargin: parent.height*0.1
            horizontalCenter: parent.horizontalCenter
        }
    }

    Rectangle{
        id:regame;   height:parent.height*0.2;   width:parent.width*0.5;   radius:parent.height*0.1;
        color:"lightgreen"
        Button{
            z:2
            background: Rectangle{color:"transparent"}
            Label{ text:"重新开始";  color:"black";  anchors.centerIn:parent}
            onClicked: {
                gamePauseDialog.close();
                stackView.replace("GameScreen.qml",{
                    "gameRunning":true
                })
            }
            anchors.fill:parent
        }
        anchors{
            top:jixu.bottom;    topMargin: parent.height*0.1
            horizontalCenter: parent.horizontalCenter
        }
    }

    Rectangle{
        id:tuichu;   height:parent.height*0.2;   width:parent.width*0.5;  radius:parent.height*0.1;
        color:"lightgreen"
        Button{
            background: Rectangle{color:"transparent"}
            Label{ text:"退出游戏";  color:"black";  anchors.centerIn:parent}
            onClicked: {
                stackView.replace("Page_jiesuan.qml",{
                    "distance":distance/16,
                    "score":score,
                    "coins_num":coin_num,
                })
                gamePauseDialog.close();
            }
            anchors.fill:parent
        }
        anchors{
            top:regame.bottom;    topMargin: parent.height*0.1
            horizontalCenter: parent.horizontalCenter
        }
    }
}

    //————————————————————————————对战功能——————————————————————————————
    function startGame() {
         gameScreen.visible = true;
        gameRunning = true;
        console.log("游戏开始！多人模式:", isMultiplayer);
    }
    // 新增游戏状态同步函数
    function syncGameState() {
        if (!isMultiplayer || !isLocalPlayer) return;

        var state = {
            score: score,
            distance: distance,
            playerX: player_x,
            playerY: player_y,
            isJumping: isJumping,
            isSliding: isSliding,
            currentGroundX: get_CurrentGround() ? get_CurrentGround().x : 0,
            currentGroundTop: get_CurrentGround() ? get_CurrentGround().top : 0
        };


        // 确保NetworkManager对象已正确初始化
        if (NetworkManager) {
            NetworkManager.sendGameState(state);
        } else {
            console.error("NetworkManager is not available");
        }
    }

    function setRandomSeed(seed) {
        var m = 2147483647;
            var a = 16807;
            var s = seed % m;
            Math.random = function() {
                s = (a * s) % m;
                return s / m;
            };

    }



    // 在适当位置添加seedrandom函数
    function seedrandom(seed) {
        // 简单的伪随机数生成器实现
        // 可以使用更复杂的算法如Mulberry32
        return function() {
            seed = (seed * 9301 + 49297) % 233280;
            return seed / 233280;
        };
    }

   // signal gameStateChanged(var state)
    // 处理接收到的对手状态
        Connections {
            target: NetworkManager
            function onGameStateReceived(state) {
                if (isMultiplayer) {
                    opponentState = state
                }
            }
        }

    // 在游戏循环中定期同步状态
    Timer {
        interval: 100 // 每100ms同步一次
        running: gameRunning && isMultiplayer && isLocalPlayer
        repeat: true
        onTriggered: syncGameState()
    }
    Connections {
        target: NetworkManager
        function onRandomSeedReceived(seed) {
            setRandomSeed(seed);
        }
    }

    // 处理远程玩家状态更新
    onGameStateChanged: {
        if (isMultiplayer && !isLocalPlayer) {
            player_x = gameState.playerX
            player_y = gameState.playerY
            isJumping = gameState.isJumping
            isSliding = gameState.isSliding
            // 更新其他状态...
        }

    }
    // 对手角色
    Player {
        id: opponentPlayer
        x: (opponentState.playerX || 0) - (gameScreen.distance - (opponentState.distance || 0)) * 0.5
        y: opponentState.playerY || 0
        height: player_height
        width: player_width
        isSliding: opponentState.isSliding || false
        isJumping: opponentState.isJumping || false
        isDowning: false
        gameRunning: gameRunning
        z: player.z - 1
        // 使用不同的外观区分对手
        Image {source:"qrc:/player/Images/player/对手.png"}
        visible: isMultiplayer && opponentState && opponentState.distance !== undefined

    }
    //比较距离
    function getDistanceDifference() {
        if (!opponentState || opponentState.distance === undefined) return 0;

        // 将游戏内部单位转换为米 (假设16单位=1米，根据你的游戏调整)
        var myDistanceMeters = Math.floor(distance / 16);
        var opponentDistanceMeters = Math.floor(opponentState.distance / 16);

        return myDistanceMeters - opponentDistanceMeters;
    }

    // 计算对手在屏幕上的x位置
    function calculateOpponentX() {
        if (!opponentState || opponentState.distance === undefined) return -100; // 屏幕外

        // 计算距离差 (游戏单位)
        var distanceDiff = distance - (opponentState.distance || 0);

        // 转换为屏幕位置 (根据你的游戏调整系数)
        var screenPos = player_normal_x + (distanceDiff * 0.2);

        // 限制在合理范围内
        return Math.max(-100, Math.min(Screen.width + 100, screenPos));
    }

    // 显示距离差异的UI组件
    Text {
        id: distanceComparison
        text: {
            var diff = getDistanceDifference();
            if (diff > 10) return "领先 " + Math.abs(diff) + " 米";
            else if (diff < -10) return "落后 " + Math.abs(diff) + " 米";
            else if (Math.abs(diff) > 3) return diff > 0 ? "略微领先" : "略微落后";
            else return "并驾齐驱";
        }
        color: {
            var diff = getDistanceDifference();
            if (diff > 10) return "green";
            else if (diff < -10) return "red";
            else return "yellow";
        }
        font.pixelSize: 24
        anchors {
            top: parent.top
            right: parent.right
            margins: 20
        }
        visible: isMultiplayer && opponentState && opponentState.distance !== undefined
    }



    //————————————————————————————奖励关卡——————————————————————————————
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

    //增加能量
    function add_energy(){
        if(!goto_bonusLevel){
            if(energy_du.width<Screen.width*0.3){
                energy_du.width+=Screen.width*0.003
                gameScreen.current_energy+=1
            }
            //进入奖励关卡，同时进度清0
            else{
                energy_du.width=0
                gameScreen.current_energy=0
                start_BonusLevel()
            }
        }
    }

    //开始奖励关卡
    function start_BonusLevel(){
        if(!goto_bonusLevel){
            goto_bonusLevel=true
            gameScreen.gameRunning=false
            //销毁地面块、障碍物、原始金币
            for(var j=0;j<activeCoins.count; j++) {  activeCoins.remove(j)  }
            obstacle_generator.destory_obstacle()
            loader.sourceComponent=bonus_level
            jiangli.start()
        }
    }

    Timer{
        id:jiangli
        repeat:false
        running:false
        interval: 10000
        onTriggered: {
            goto_bonusLevel=false
            loader.sourceComponent=null
            gameScreen.gameRunning=true
        }
    }
}
