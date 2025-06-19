import QtQuick
import QtQuick.Window
import QtQuick.Controls

//障碍物页面

Item {
    id: obstacleGenerator

    //传入参数
    property bool gameRunning: false
    property ListModel activeGrounds: ListModel{}            //地面块容器
    property int  speed                                      //游戏速度
    property bool ground_hasBigGap:false                     //具有长空缺(用于弹簧逻辑)
    property var  tanhuang_ground:({})                       //具有弹簧的地面块
    property bool goto_bonusLevel:false                      //进入奖励关卡

    //传入角色参数
    property int  player_x                                   //人物X坐标
    property int  player_y                                   //人物Y坐标
    property int  player_height                              //人物高度
    property int  player_width                               //人物宽度
    property int  player_slide_height                        //人物滑铲高度
    property bool isJumping:false                            //是否在跳跃

    property int  player_normal_x                            //玩家初始x坐标

    // 障碍物生成参数
    property int  minObstacleSpacing: Screen.width*0.13      // 障碍物最小间距
    property real missileChance: 0.4                         // 导弹生成概率
    property real wallChance: 0.3                            // 墙体生成概率
    property int  lastSpawnTime: 0

    // 导弹参数
    property int  missileSpeed: 50
    property int  missileHeight: 15

    // 墙体参数
    property int  wall_width:Screen.width*0.05                //墙体宽度
    property var  sliding_wall:({})                           //正进行滑铲中的墙

    //小怪物参数
    property int  guaiwu_height:Screen.height*0.12            //小怪物的高
    property int  guaiwu_width:guaiwu_height                  //小怪物的宽

    //地刺参数
    property int  dici_height:Screen.height*0.12              //地刺的高
    property int  dici_width:Screen.width*0.05                //地刺的宽

    //弹簧参数
    property int  tanhuang_width:screen.width*0.05
    property int  tanhuang_height:tanhuang_width
    property real tanhuang_compress_ratio: 0.3 // 压缩比例
    property real tanhuang_stretch_ratio: 1.8   // 拉伸变宽比例
    property int compress_duration: 100  // 压缩动画持续时间(ms)


    signal movePlayer(int change_x)                           //修改角色x值
    signal mustSlideKeep()                                    //开始滑铲锁定
    signal mustSlide()                                        //需要进行滑铲
    signal mustSlideEnd()                                     //停止滑铲锁定
    signal playerDead()                                       //人物死亡
    signal tanhuangJump()                                     //信号：踩到弹簧
    signal readyTanhuang()                                    //弹簧已经生成
    signal addEnergy()                                        //增加能量

    property var obstacles_type: ["wall","xiaoguaiwu","dici"]
    property var obstacles_img: [
        "qrc:/obstacle/Images/obstacle/墙.png",
        "qrc:/obstacle/Images/obstacle/小怪物.png",
        "qrc:/obstacle/Images/obstacle/地刺.png",
    ]

    ListModel { id: active_obstacles }     //障碍物容器
    ListModel {  id:active_tanhuang }      //弹簧容器

    //障碍物生成
    function generateObstacle(){
        var index=Math.floor(Math.random()*obstacles_type.length)
        var obstacle =obstacles_type[index]
        var img=obstacles_img[index]

        switch(obstacle){
        case "wall":
            spawnWall(img)
            break
        case "xiaoguaiwu":
            spawnXiaoguaiwu(img)
            break
        case "dici":
            spawnDici(img)
            break
        }
    }

    //障碍物生成计时器
    Timer {
        interval: 500
        running: obstacleGenerator.gameRunning &&!goto_bonusLevel
        repeat: true
        onTriggered: {
            generateObstacle()
            generator_tanhuang()
        }
    }

    // 生成导弹
    function spawnMissile() {
        var missile = missileComponent.createObject(parent)
        missile.y = getHighestGroundTop() - missileHeight
        missile.x = parent.width
        obstacles.push(missile)
    }

    //生成墙体
    function spawnWall(img)
    {
        var lastground=activeGrounds.get(activeGrounds.count-1)
        var wall_x=lastground.x+minObstacleSpacing

        //检查所有障碍物,保证不会重叠
        for(var i=0;i<active_obstacles.count;i++){
            var obstacle=active_obstacles.get(i)
            if(Math.abs(wall_x-obstacle.x)<minObstacleSpacing){
                wall_x=obstacle.x+obstacle.width+minObstacleSpacing
            }
        }

        for(var j=0;j<active_tanhuang.count;j++){
            var tanhuang=active_tanhuang.get(j)
            if(Math.abs(wall_x-tanhuang.x)<minObstacleSpacing){
                return
            }
        }

        var wall_height=lastground.top-player_slide_height*1.2
        var panding=(wall_x+wall_width)<(lastground.x+lastground.width)
        if(!lastground.hasGap && lastground.is_longGround && panding && lastground.spawn_obstacle){
            active_obstacles.append({
            "x":wall_x,
            "y":0,
            "height":wall_height,
            "width":obstacleGenerator.wall_width,
            "img":img,              //保存资源图片
            "type":"wall"
            })
        }
    }

    //生成小怪物
    function spawnXiaoguaiwu (img){
        var lastground=activeGrounds.get(activeGrounds.count-1)
        var guaiwu_x=lastground.x+minObstacleSpacing

        //检查所有障碍物,保证不会重叠
        for(var i=0;i<active_obstacles.count;i++){
            var obstacle=active_obstacles.get(i)
            if(Math.abs(guaiwu_x-obstacle.x)<minObstacleSpacing){
                guaiwu_x=obstacle.x+obstacle.width+minObstacleSpacing
            }
        }

        var guaiwu_y=lastground.top-guaiwu_height
        var panding=(guaiwu_x+guaiwu_width)<(lastground.x+lastground.width)
        if(!lastground.hasGap && lastground.is_longGround && panding && lastground.spawn_obstacle){
            active_obstacles.append({
            "x":guaiwu_x,
            "y":guaiwu_y,
            "height":guaiwu_height,
            "width":guaiwu_width,
            "img":img,              //保存资源图片
            "type":"xiaoguaiwu",
            "isDangerous": true,     // 添加危险状态标识
            "appearProgress": 0      // 添加出现进度属性
            })
        }
    }

   //生成地刺
    function spawnDici ( img )
    {
        var lastground=activeGrounds.get(activeGrounds.count-1)
        var dici_x=lastground.x+minObstacleSpacing

        //检查所有障碍物,保证不会重叠
        for(var i=0;i<active_obstacles.count;i++){
            var obstacle=active_obstacles.get(i)
            if(Math.abs(dici_x-obstacle.x)<minObstacleSpacing){
                dici_x=obstacle.x+obstacle.width+minObstacleSpacing
            }
        }

        var dici_y=lastground.top-dici_height
        var panding=(dici_x+dici_width)<(lastground.x+lastground.width)
        if(!lastground.hasGap && lastground.is_longGround && panding && lastground.spawn_obstacle){
            active_obstacles.append({
            "x":dici_x,
            "y":dici_y,
            "height":dici_height,
            "width":dici_width,
            "img":img,              //保存资源图片
            "type":"dici"
            })
        }
    }

    function setTimeout(callback, delay) {
        timer.setTimeout(callback, delay)
    }

    Timer {
        id: timer
        function setTimeout(cb, delay) {
            timer.interval = delay;
            timer.repeat = false;
            timer.triggered.connect(cb);
            timer.triggered.connect(function() {
                timer.triggered.disconnect(cb);
                timer.triggered.disconnect(arguments.callee);
            });
            timer.start();
        }
    }

   //生成弹簧
    function generator_tanhuang(){
        var is_chufa=false
        if(tanhuang_ground) {
            var tanhuang_x = tanhuang_ground.x + tanhuang_ground.width - tanhuang_width
            var tanhuang_y = tanhuang_ground.top - tanhuang_height

            for(var i=0;i<active_tanhuang.count;i++){
                var tanhuang=active_tanhuang.get(i)
                if(Math.abs(tanhuang_x-tanhuang.x)<minObstacleSpacing){
                    return
                }
            }

            for(var j=0;j<active_obstacles.count;j++){
                var obstacle=active_obstacles.get(j)
                if(obstacle.type==="wall"){
                    if(Math.abs(tanhuang_x-obstacle.x)<minObstacleSpacing){
                        return
                    }
                }
            }

            if(ground_hasBigGap && tanhuang_ground){
                active_tanhuang.append({
                    "x": tanhuang_x,
                    "y": tanhuang_y,
                    "width": tanhuang_width,
                    "height": tanhuang_height,
                    "is_chufa": is_chufa,
                    "original_x": tanhuang_x,
                    "original_y": tanhuang_y,
                    "original_width": tanhuang_width,
                    "original_height": tanhuang_height,
                    "is_compressing": false,
                    "is_stretching": false,
                    "appearProgress": 0  // 添加出现进度属性
                })
                obstacleGenerator.readyTanhuang()
            }
        }
    }

    //弹簧碰撞检测:
    function collision(){
        if(active_tanhuang){
            for(var i=0;i<active_tanhuang.count;i++) {
                var tanhuang=active_tanhuang.get(i)
                //人物被弹簧推走 - 显示变宽效果
                if(player_x < tanhuang.x+tanhuang.width &&
                   player_x+player_width > tanhuang.x &&
                   player_y+player_height > tanhuang.y){
                    obstacleGenerator.movePlayer(-speed)
                    console.log("进入弹簧判定————人物被推走")
                    active_tanhuang.setProperty(i, "is_stretching", true)
                    setTimeout(function() {
                        active_tanhuang.setProperty(i, "is_stretching", false)
                    }, compress_duration)
                }
                //弹簧弹走 - 显示压缩效果
                if(player_x < tanhuang.x+tanhuang.width &&
                   player_x+player_width > tanhuang.x &&
                   player_y+player_height < tanhuang.y &&
                   player_y+player_height > tanhuang.y*0.95 &&
                   !tanhuang.is_chufa && !isJumping){
                    active_tanhuang.setProperty(i, "is_chufa", true)
                    active_tanhuang.setProperty(i, "is_compressing", true)
                    setTimeout(function() {
                        active_tanhuang.setProperty(i, "is_compressing", false)
                    }, compress_duration)
                    obstacleGenerator.tanhuangJump()
                    console.log("进入弹簧判定2————人物被弹走")
                    break
                }
            }
        }
    }

        //障碍物销毁，用于奖励关卡调用
        function destory_obstacle(){
            for(var i=0;i<active_obstacles.count;i++){  active_obstacles.remove(i)  }
            for(var j=0;j<active_tanhuang.count;j++){   active_tanhuang.remove(j)  }
        }

        Component {
            id: missileComponent
            Item {
                id: missile
                width: 80  // 根据图片实际尺寸调整
                height: 40
                property bool active: true

            // 导弹主体图片
            Image {
                id: missileBody
                anchors.fill: parent
                source: "qrc:/images/weapons/missile_body.png"
                fillMode: Image.PreserveAspectFit
            }
        }
    }

    Repeater{
        model:active_obstacles
            delegate: Item {
            x: model.x
            y: model.type === "xiaoguaiwu" ? model.y :
               (model.y + (1 - (model.appearProgress || 1)) * model.height)
            width: model.width
            height: model.height
            opacity: model.type === "xiaoguaiwu" ? (model.appearProgress || 1) : 1

            // 小怪物本体
            Rectangle {
                id: obstacleRect
                anchors.fill: parent
                color: "transparent"

                Image {
                    anchors.fill: parent
                    source: model.img
                    opacity: model.type === "xiaoguaiwu" ? (model.appearProgress || 1) : 1
                }

            // 危险边缘效果 - 红色边框
                Rectangle {
                    visible: model.type === "xiaoguaiwu" && model.isDangerous
                    anchors.fill: parent
                    color: "transparent"
                    border.color: "red"
                    border.width: 2
                    radius: 2
                    opacity: model.appearProgress || 1
                }
            }

            // 危险闪光效果
            Rectangle {
                visible: model.type === "xiaoguaiwu" && model.isDangerous
                anchors.centerIn: parent
                width: parent.width * 1.5
                height: parent.height * 1.5
                color: "transparent"
                border.color: "#FF4500"  // 橙红色
                border.width: 3
                radius: width/2
                opacity: (model.appearProgress || 1) * 0.5

                SequentialAnimation on opacity {
                    running: (model.appearProgress || 1) >= 1
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.7; duration: 800 }
                    NumberAnimation { to: 0; duration: 800 }
                }

                SequentialAnimation on scale {
                    running: (model.appearProgress || 1) >= 1
                    loops: Animation.Infinite
                    NumberAnimation { to: 1.2; duration: 800 }
                    NumberAnimation { to: 1.0; duration: 800 }
                }
            }
        }
    }

    Repeater{
        model: active_tanhuang
            delegate: Item {
            id: springItem
            x: model.x
            y: model.y + (1 - (model.appearProgress || 1)) * model.height
            width: model.original_width
            height: model.original_height

                Rectangle {
                    id: springRect
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: parent.height
                    color: "transparent"
                    opacity: model.appearProgress || 1

                    transform: [
                        Scale {
                        id: widthScale
                        origin.x: springRect.width/2
                        origin.y: springRect.height
                        xScale: model.is_stretching ? tanhuang_stretch_ratio :
                               (model.is_compressing ? 1 : 1)
                        },
                        Scale {
                        id: heightScale
                        origin.x: springRect.width/2
                        origin.y: springRect.height
                        yScale: model.is_compressing ? tanhuang_compress_ratio :
                           (model.is_stretching ? 1 : 1)
                    }
                ]

                Behavior on transform {
                    enabled: (model.appearProgress || 1) >= 1
                    ParallelAnimation {
                        NumberAnimation {
                            target: widthScale
                            property: "xScale"
                            duration: compress_duration
                        }
                        NumberAnimation {
                            target: heightScale
                            property: "yScale"
                            duration: compress_duration
                        }
                    }
                }

                Image {
                    anchors.fill: parent
                    source: "qrc:/obstacle/Images/obstacle/弹簧.png"
                }
            }
        }
    }


//障碍物逻辑处理
    Timer {
        interval: 16
        running: obstacleGenerator.gameRunning
        repeat: true
        onTriggered: {
            //————————————————————————————墙体障碍物——————————————————————————————
            for(var i = 0; i < active_obstacles.count; i++) {
                // 移动障碍物
                active_obstacles.setProperty(i, "x", active_obstacles.get(i).x - speed)

                // 碰撞检测
                var current_obstacle = active_obstacles.get(i)

                // 墙体碰撞检测
                if(current_obstacle.type === "wall") {
                    if(player_x < current_obstacle.x && player_x + player_width >= current_obstacle.x) {
                        if(gameScreen.isEnlarged) {
                            // 角色处于变大状态，消除墙体
                            active_obstacles.remove(i);
                            i--; // 调整索引，因为列表已更改
                        }
                        else if(player_y < current_obstacle.height) {
                            obstacleGenerator.sliding_wall = current_obstacle
                            obstacleGenerator.movePlayer(-speed)
                            obstacleGenerator.mustSlide()
                        }
                    }
                }
                // 小怪物碰撞检测（包含发光圆环）
                else if(current_obstacle.type === "xiaoguaiwu") {
                    // 计算小怪物中心位置
                    var guaiwuCenterX = current_obstacle.x + current_obstacle.width/2
                    var guaiwuCenterY = current_obstacle.y + current_obstacle.height/2

                    // 计算玩家中心位置
                    var playerCenterX = player_x + player_width/2
                    var playerCenterY = player_y + player_height/2

                    // 计算两者距离
                    var dx = playerCenterX - guaiwuCenterX
                    var dy = playerCenterY - guaiwuCenterY
                    var distance = Math.sqrt(dx*dx + dy*dy)

                    // 发光圆的半径（比小怪物稍大）
                    var dangerRadius = current_obstacle.width * 1.2

                    // 两种碰撞情况都会导致死亡：
                    // 1. 直接碰到小怪物本体
                    // 2. 碰到发光圆环
                    if((player_x + player_width > current_obstacle.x * 1.1 &&
                        player_x < current_obstacle.x + current_obstacle.width * 0.9 &&
                        player_y < current_obstacle.y + current_obstacle.height &&
                        player_y + player_height > current_obstacle.y * 1.1) ||
                       (distance < dangerRadius)) {
                        if(gameScreen.isShielded || gameScreen.isEnlarged) {
                            active_obstacles.remove(i);
                            i--;
                        }
                        else {
                            obstacleGenerator.playerDead()
                        }
                    }
                }
            // 地刺碰撞检测
                else if(current_obstacle.type === "dici") {
                    if(player_x + player_width > current_obstacle.x * 1.1 &&
                       player_x < current_obstacle.x + current_obstacle.width * 0.9 &&
                       player_y < current_obstacle.y + current_obstacle.height &&
                       player_y + player_height > current_obstacle.y * 1.1) {
                        if(gameScreen.isShielded || gameScreen.isEnlarged) {
                            active_obstacles.remove(i);
                            i--;
                        }
                        else {
                            obstacleGenerator.playerDead()
                        }
                    }
                }
            }

            // 移动弹簧
            for(var j = 0; j < active_tanhuang.count; j++) {
                active_tanhuang.setProperty(j, "x", active_tanhuang.get(j).x - speed)
            }

        // 销毁弹簧（释放资源）
            while(active_tanhuang.count > 0 && active_tanhuang.get(0).x + minObstacleSpacing * 4 < 0) {
                active_tanhuang.remove(0)
                obstacleGenerator.addEnergy()
            }

        // 弹簧碰撞检测
            collision()

            //——————————————————————————墙体逻辑判定——————————————————————
            // 锁定滑铲
            if(sliding_wall && player_x > sliding_wall.x && player_x <= sliding_wall.x + wall_width) {
                obstacleGenerator.mustSlideKeep()
            }

            // 恢复原始位置
            if(sliding_wall && player_x > sliding_wall.x + wall_width) {
                obstacleGenerator.mustSlideEnd()
            }

            // 移除超出屏幕障碍物
            while(active_obstacles.count > 0 && active_obstacles.get(0).x + minObstacleSpacing * 4 < 0) {
                active_obstacles.remove(0)
                obstacleGenerator.addEnergy()
            }
        }
    }
}
