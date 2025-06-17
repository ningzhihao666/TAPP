import QtQuick

Item {
    id: daojudetector

    property var player
    property var obstacles: []
    property ListModel daojus: ListModel {}
    property bool isAttracting: false
    property int attractDuration: 5000  // 吸引力持续5秒
    property var coinGenerator


    signal daojuCollected()
    signal obstacleHit()
    signal wallHit(var wall)
    signal attractActivated(int duration)  // 吸引力激活信号
    signal enlargeActivated(int duration)
    signal shieldActivated(int duration)

    property int  minObstacleSpacing: Screen.width*0.1       // 障碍物最小间距

    Timer {
        interval: 10 // 约60fps
        running: true
        repeat: true
        onTriggered: checkCollisions()
    }

    function checkCollisions() {
        for (var i = daojus.count - 1; i >= 0; i--) {
            var daoju = daojus.get(i).object;
            if (collides(player, daoju)) {
                if (daoju.type === "box") {
                    var topCollider = {
                        x: daoju.x,
                        y: daoju.y,
                        width: daoju.width,
                        height: daoju.height * 0.2
                };

                // 检查玩家是否在碰撞区域内
                const isInCollisionArea = player.y + player.height <= topCollider.y + topCollider.height + 5 &&
                                        player.y + player.height >= topCollider.y &&
                                        player.x + player.width > topCollider.x &&
                                        player.x < topCollider.x + topCollider.width;

                if (isInCollisionArea) {
                    // 在碰撞区域内
                    jump();
                    daojugenerator.removeDaoju(daoju);
                    daojugenerator.spawnReward(daoju);
                    i--;
                }
                else {
                    // 不在碰撞区域内
                    if (isEnlarged) daojugenerator.removeDaoju(daoju);
                    else {
                        player_x -= speed;
                        if(player_x+player_width<=0){ gameOver();  return}
                    }
                }
            }
            else {
                switch(daoju.type) {
                    case "double":
                        daojuCollected();
                        break;
                    case "attract":
                        attractActivated(5000);
                        break;
                    case "enlarge":
                        enlargeActivated(2000);
                        break;
                    case "shield":
                        shieldActivated(2000);
                        break;
                }
                    daojugenerator.removeDaoju(daoju);
            }
            }
        }
    }

   function collides(obj1, obj2) {
       return obj1.x < obj2.x + obj2.width &&
              obj1.x + obj1.width > obj2.x &&
              obj1.y < obj2.y + obj2.height &&
              obj1.y + obj1.height > obj2.y;
   }
}
