import QtQuick

Item {
    id: daojugenerator

    //传入参数
    property int  speed:sc_x*1
    property bool running: false

    property ListModel daojus: ListModel {}
    property int initialDelay: 1000
    property int spawnInterval: 2000
    property int lastSpawnTime: 0
    property real minBoxGap: 500
    property real attractChance: 0.1
    property real enlargeChance: 0.9
    property int maxTotal: 3
    property int maxPerType: 2
    property var typeCount: ({
           "double": 0,
           "attract": 0,
           "enlarge": 0
       })
    property bool validParent: parent && parent.width > 0 && parent.height > 0
    property ListModel activeGrounds: ListModel {}
    property int consecutiveCount: 0
    property bool coolingDown: false

    //箱子属性
    property int boxwidth:boxheight //箱子宽
    property int boxheight:Screen.height*0.10 //箱子高

    //道具属性
    property int daoju_height:Screen.height*0.07
    property int daoju_width:Screen.height*0.07

    //屏幕比例属性
    property int sc_x: Screen.width / 200
    property int sc_y: Screen.height / 100

    Timer {
        id: spawnTimer
        interval: 16
        running: daojugenerator.running && daojugenerator.validParent && !daojugenerator.coolingDown
        repeat: true
        onTriggered: {
            var currentTime = new Date().getTime()
            if (currentTime - daojugenerator.lastSpawnTime < daojugenerator.initialDelay) return
            spawndaoju()

            // 清理屏幕外的箱子
            while(daojus.count>0&&daojus.get(0).x+daojus.get(0).width<0){
                daojus.remove(0)
            }

            lastSpawnTime = currentTime
        }
    }

    function spawnReward(box) {
        const rewardTypes = ["double", "attract", "enlarge","coin","shield"];
        var index=Math.floor(Math.random()*rewardTypes.length)
        const type =rewardTypes[index];

        var reward;
        var rewardProperties = {
            type: type,  // 保存奖励类型
            object: null,  // 稍后赋值
            x: box.x + box.width / 2,
            y: box.y + box.height / 2 + 5* sc_y,
            targetX: gameScreen.width / 2,
            targetY: gameScreen.height / 2,
            originalY: box.y + box.height / 2 - (type === "enlarge" ? 30 : 25) * sc_y,
            speed: 3,
            amplitude: 30 * sc_y,
            waveSpeed: 0.05,
            rotationSpeed: Math.random() * 2 - 1
        };

        switch (type) {
            case "double":
                reward = doubleComponent.createObject(gameScreen, rewardProperties);
                break;
            case "attract":
                reward = attractDaojuComponent.createObject(gameScreen, rewardProperties);
                break;
            case "enlarge":
                reward = enlargeComponent.createObject(gameScreen, rewardProperties);
                break;
            case "shield":
                reward = shieldComponent.createObject(gameScreen, rewardProperties);
                break;

        }

        if (reward) {
            // 将奖励对象和属性添加到ListModel
            daojus.append({
                "type": type,
                "object": reward,
                "x": reward.x,
                "y": reward.y
                // 可以添加其他需要跟踪的属性
            });

            // 启动移动动画
            reward.moveToCenter.start();
        }
    }

    function spawndaoju() {
        if (coolingDown || daojus.count >= maxTotal || activeGrounds.count === 0) return;

        var ground = activeGrounds.get(activeGrounds.count - 1);
        var boxWidth = boxwidth;
        var boxHeight = boxheight;
        var startX =ground.x+boxWidth;
        var spawnCount = Math.floor(Math.random() * 3) + 1;

        var isLongGround = ground.is_longGround;
        var hasGap = ground.hasGap;
        var groundTop = ground.top;

        if(!ground.spawn_daoju) return

        for (let i = 0; i < spawnCount; i++) {
            var newX =startX+i*boxWidth;
            newX = Math.max(newX, 0);
            var yPosition = groundTop - boxHeight;

            if (!hasGap && isLongGround) {
                var box = boxComponent.createObject(parent, {
                    x: newX,
                    y: yPosition,
                    groundRef: ground,
                    speed: daojugenerator.speed,
                    width: boxWidth,
                    height: boxHeight
                });

                if (box) {
                    daojus.append({
                        "object": box,
                        "x": newX,
                        "width": boxWidth,
                        "height": boxHeight,
                        "type": "box"
                    });
                }
            }
            else if (hasGap && Math.random() < 0.8) {
                var gapStart = ground.x + ground.width;
                var gapEnd = gapStart + ground.gapWidth;
                var gapWidth = gapEnd - gapStart;

                var gapBoxCount = Math.floor(Math.random() * (gapWidth / boxWidth)) + 1;
                var boxesGenerated = 0;

                for (let j = 0; j < gapBoxCount && boxesGenerated < gapWidth; j++) {
                    var boxWidthInGap = Math.min(boxWidth, gapWidth - boxesGenerated);
                    var boxX = gapStart + boxesGenerated;
                    var boxY = groundTop - boxHeight;

                    var box = boxComponent.createObject(parent, {
                        x: boxX,
                        y: boxY,
                        groundRef: ground,
                        speed: daojugenerator.speed,
                        width: boxWidthInGap,
                        height: boxHeight
                    });

                    if (box) {
                        daojus.append({
                            "object": box,
                            "x": boxX,
                            "width": boxWidthInGap,
                            "height": boxHeight,
                            "type": "box"
                        });
                        boxesGenerated += boxWidthInGap;
                    }
                }
            }
        }

        consecutiveCount += spawnCount;
        if (consecutiveCount >= 3) {
            coolingDown = true;
            consecutiveCount = 0;
            coolDownTimer.start();
            lastSpawnTime = new Date().getTime();
        }
    }
    Timer {
        id: coolDownTimer
        interval: 2000
        onTriggered: daojugenerator.coolingDown = false
    }

    function removeDaoju(daoju) {
        for (var i = 0; i < daojus.count; i++) {
            var item = daojus.get(i);
            if (item.object === daoju) {
                daojus.remove(i);
                daoju.destroy();
                break;
            }
        }
    }

    Component {
        id: boxComponent
        Rectangle {
            property string type: "box"
            property var groundRef
            property real speed: 0
            property bool isTouched: false
            color: "transparent"

            Rectangle {
                anchors.top: parent.top

                width: parent.width
                height: parent.height * 0.2
                color: "transparent"
            }
            Image{
                source:"qrc:/daoju/Images/daoju/箱子.png"
                anchors.fill:parent
            }

            Timer {
                interval: 16
                running: daojugenerator.running
                repeat: true
                onTriggered: {
                    parent.x -= parent.speed
                    if (parent.x < -parent.width) {
                        daojugenerator.removeDaoju(parent)
                    }
                    if (parent.groundRef) parent.y = parent.groundRef.top - parent.height
                }
            }
        }
    }

    Component {
        id: doubleComponent
        Rectangle {
            property string type: "double"
            id: doubledaoju
            width: daoju_width
            height: daoju_height
            radius: width/2
            color: "red"
            border.color: "white"

            // 移动控制属性
            property real targetX: gameScreen.width / 2
            property real targetY: gameScreen.height / 2
            property real originalY: y
            property real speed: 3
            property real amplitude: 1 * sc_y
            property real waveSpeed: 0.001
            property real rotationSpeed: Math.random() * 2 - 1
            property real waveOffset: Math.random() * Math.PI * 2
            property bool movingToCenter: true
            Image{
                source:"qrc:/daoju/Images/daoju/X2.png"
                anchors.fill:parent
            }

            // 动画控制
            ParallelAnimation {
                id: moveToCenter
                running: false

                NumberAnimation {
                    target: doubledaoju
                    property: "x"
                    to: doubledaoju.targetX
                    duration: 1000
                    easing.type: Easing.OutQuad
                }

                NumberAnimation {
                    target: doubledaoju
                    property: "y"
                    to: doubledaoju.targetY
                    duration: 1000
                    easing.type: Easing.OutQuad
                }

                onFinished: {
                    movingToCenter = false;
                    waveAnimation.start();
                }
            }

            // 波浪移动动画
            Timer {
                id: waveAnimation
                interval: 16
                running: false
                repeat: true
                onTriggered: {
                    if (!daojugenerator.running || doubledaoju.x < -doubledaoju.width) {
                        daojugenerator.removeDaoju(doubledaoju);
                        return;
                    }

                    // 向左移动
                    doubledaoju.x -= doubledaoju.speed;

                    // 波浪效果 - 使用正弦函数计算Y偏移
                    var time = new Date().getTime() * doubledaoju.waveSpeed + doubledaoju.waveOffset;
                    var waveY = Math.sin(time/25) * doubledaoju.amplitude;
                    doubledaoju.y = doubledaoju.targetY + waveY;

                    // 旋转
                    doubledaoju.rotation += doubledaoju.rotationSpeed;
                }
            }

            Component.onCompleted: {
                moveToCenter.start();
            }

            Text {
                text: "2x"
                anchors.centerIn: parent
                color: "white"
                font.bold: true
                font.pixelSize: 2 * sc_y
            }
            RotationAnimation on rotation {
                from: 0
                to: 360
                duration: 2000
                loops: Animation.Infinite
                running: true
            }
            SequentialAnimation on scale {
                loops: Animation.Infinite
                NumberAnimation { to: 1.2; duration: 800; easing.type: Easing.OutQuad }
                NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InQuad }
            }
        }
    }

    Component {
        id: enlargeComponent
        Rectangle {
            property string type: "enlarge"
            id: enlargeDaoju
            width: daoju_width
            height: daoju_height
            radius: 1 * sc_x
            color: "#FFA500"
            border.color: "black"

            // 移动控制属性
            property real targetX: gameScreen.width / 2
            property real targetY: gameScreen.height / 2
            property real originalY: y
            property real speed: 3
            property real amplitude: 2 * sc_y
            property real waveSpeed: 0.001
            property real rotationSpeed: Math.random() * 2 - 1
            property real waveOffset: Math.random() * Math.PI * 2
            property bool movingToCenter: true

            Image{
                source:"qrc:/daoju/Images/daoju/变大.png"
                anchors.fill:parent
            }
            // 动画控制
            ParallelAnimation {
                id: moveToCenter
                running: false

                NumberAnimation {
                    target: enlargeDaoju
                    property: "x"
                    to: enlargeDaoju.targetX
                    duration: 1000
                    easing.type: Easing.OutQuad
                }

                NumberAnimation {
                    target: enlargeDaoju
                    property: "y"
                    to: enlargeDaoju.targetY
                    duration: 1000
                    easing.type: Easing.OutQuad
                }

                onFinished: {
                    movingToCenter = false;
                    waveAnimation.start();
                }
            }

            // 波浪移动动画
            Timer {
                id: waveAnimation
                interval: 16
                running: false
                repeat: true
                onTriggered: {
                    if (!daojugenerator.running || enlargeDaoju.x < -enlargeDaoju.width) {
                        daojugenerator.removeDaoju(enlargeDaoju);
                        return;
                    }

                    // 向左移动
                    enlargeDaoju.x -= enlargeDaoju.speed;

                    // 波浪效果 - 使用正弦函数计算Y偏移
                    var time = new Date().getTime() * enlargeDaoju.waveSpeed + enlargeDaoju.waveOffset;
                    var waveY = Math.sin(time/25) * enlargeDaoju.amplitude;
                    enlargeDaoju.y = enlargeDaoju.targetY + waveY;

                    // 旋转
                    enlargeDaoju.rotation += enlargeDaoju.rotationSpeed;
                }
            }

            Component.onCompleted: {
                moveToCenter.start();
            }
        }
    }

    Component {
        id: attractDaojuComponent
        Rectangle {
            id: attractDaoju
            property string type: "attract"
            width: daoju_width
            height: daoju_height
            radius: width/2
            color: "#00FF00"
            border.color: "white"

            // 移动控制属性
            property real targetX: gameScreen.width / 2
            property real targetY: gameScreen.height / 2
            property real originalY: y
            property real speed: 3
            property real amplitude: 30 * sc_y
            property real waveSpeed: 0.001
            property real rotationSpeed: Math.random() * 2 - 1
            property real waveOffset: Math.random() * Math.PI * 2
            property bool movingToCenter: true
            Image{
                source:"qrc:/daoju/Images/daoju/磁铁.png"
                anchors.fill:parent
            }

            // 动画控制
            ParallelAnimation {
                id: moveToCenter
                running: false

                NumberAnimation {
                    target: attractDaoju
                    property: "x"
                    to: attractDaoju.targetX
                    duration: 1000
                    easing.type: Easing.OutQuad
                }

                NumberAnimation {
                    target: attractDaoju
                    property: "y"
                    to: attractDaoju.targetY
                    duration: 1000
                    easing.type: Easing.OutQuad
                }

                onFinished: {
                    attractDaoju.movingToCenter = false;
                    waveAnimation.start();
                }
            }

            // 波浪移动动画
            Timer {
                id: waveAnimation
                interval: 16
                running: false
                repeat: true
                onTriggered: {
                    if (!daojugenerator.running || attractDaoju.x < -attractDaoju.width) {
                        daojugenerator.removeDaoju(attractDaoju);
                        return;
                    }

                    // 向左移动
                    attractDaoju.x -= attractDaoju.speed;

                    // 波浪效果 - 使用正弦函数计算Y偏移
                    var time = new Date().getTime() * attractDaoju.waveSpeed + attractDaoju.waveOffset;
                    var waveY = Math.sin(time/25) * attractDaoju.amplitude;
                    attractDaoju.y = attractDaoju.targetY + waveY;

                    // 旋转
                    attractDaoju.rotation += attractDaoju.rotationSpeed;
                }
            }

            Component.onCompleted: {
                moveToCenter.start();
            }
        }
    }
    Component {
        id: shieldComponent
        Rectangle {
            property string type: "shield"
            id: shieldDaoju
            width: daoju_width
            height: daoju_height
            radius: 1 * sc_x
            color: "#00BFFF"  // 护盾颜色
            border.color: "black"

            // 移动控制属性
            property real targetX: gameScreen.width / 2
            property real targetY: gameScreen.height / 2
            property real originalY: y
            property real speed: 3
            property real amplitude: 2 * sc_y
            property real waveSpeed: 0.001
            property real rotationSpeed: Math.random() * 2 - 1
            property real waveOffset: Math.random() * Math.PI * 2
            property bool movingToCenter: true

            // 动画控制
            ParallelAnimation {
                id: moveToCenter
                running: false

                NumberAnimation {
                    target: shieldDaoju
                    property: "x"
                    to: shieldDaoju.targetX
                    duration: 1000
                    easing.type: Easing.OutQuad
                }

                NumberAnimation {
                    target: shieldDaoju
                    property: "y"
                    to: shieldDaoju.targetY
                    duration: 1000
                    easing.type: Easing.OutQuad
                }

                onFinished: {
                    movingToCenter = false;
                    waveAnimation.start();
                }
            }

            // 波浪移动动画
            Timer {
                id: waveAnimation
                interval: 16
                running: false
                repeat: true
                onTriggered: {
                    if (!daojugenerator.running || shieldDaoju.x < -shieldDaoju.width) {
                        daojugenerator.removeDaoju(shieldDaoju);
                        return;
                    }

                    // 向左移动
                    shieldDaoju.x -= shieldDaoju.speed;

                    // 波浪效果 - 使用正弦函数计算Y偏移
                    var time = new Date().getTime() * shieldDaoju.waveSpeed + shieldDaoju.waveOffset;
                    var waveY = Math.sin(time/25) * shieldDaoju.amplitude;
                    shieldDaoju.y = shieldDaoju.targetY + waveY;

                    // 旋转
                    shieldDaoju.rotation += shieldDaoju.rotationSpeed;
                }
            }

            Component.onCompleted: {
                moveToCenter.start();
            }
        }
    }
}
