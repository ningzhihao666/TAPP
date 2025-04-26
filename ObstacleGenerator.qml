import QtQuick 2.15

//障碍物生成逻辑

Item {
    id: generator
    property bool running: false
    property var obstacles: []          //存储障碍物对象

    property int spawnInterval: 2000 // 2秒生成一个障碍物
    property int lastSpawnTime: 0

    Timer {
        id: spawnTimer
        interval: 50
        running: generator.running
        repeat: true
        onTriggered: {
            var currentTime = new Date().getTime()
            if (currentTime - lastSpawnTime > spawnInterval) {
                spawnObstacle()
                lastSpawnTime = currentTime
                // 随着时间推移，增加难度
                if (spawnInterval > 800) {
                    spawnInterval -= 50
                }
            }
        }
    }

    //生成障碍物
    function spawnObstacle() {
        var obstacle = obstacleComponent.createObject(generator.parent)
        obstacle.x = generator.parent.width
        obstacles.push(obstacle)
    }

    //移除障碍物
    function removeObstacle(obstacle) {
        var index = obstacles.indexOf(obstacle)
        if (index !== -1) {
            obstacles.splice(index, 1)
        }
        obstacle.destroy()
    }

    Component {
        id: obstacleComponent
        Rectangle {
            id: obstacle
            width: 40
            height: 60
            color: "brown"

            property int speed: 10

            Timer {
                interval: 16
                running: generator.running
                repeat: true
                onTriggered: {
                    obstacle.x -= speed
                    if (obstacle.x < -obstacle.width) {
                        generator.removeObstacle(obstacle)
                    }
                }
            }
        }
    }
}
