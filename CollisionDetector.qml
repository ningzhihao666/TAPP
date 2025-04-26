import QtQuick

Item {
    id: detector

    property var player
    property var obstacles: []
    property var coins: []

    signal coinCollected()
    signal obstacleHit()

    Timer {
        interval: 16 // 约60fps
        running: true
        repeat: true
        onTriggered: checkCollisions()
    }

    function checkCollisions() {
        // 检查与金币的碰撞
        for (var i = 0; i < coins.length; i++) {
            var coin = coins[i]
            if (collides(player, coin)) {
                coinCollected()
                coins.splice(i, 1)
                coin.destroy()
                i--
            }
        }

        // 检查与障碍物的碰撞
        for (var j = 0; j < obstacles.length; j++) {
            if (collides(player, obstacles[j])) {
                obstacleHit()
                break
            }
        }
    }

    function collides(obj1, obj2) {
        // 简单的矩形碰撞检测
        return obj1.x < obj2.x + obj2.width &&
               obj1.x + obj1.width > obj2.x &&
               obj1.y < obj2.y + obj2.height &&
               obj1.y + obj1.height > obj2.y
    }
}
