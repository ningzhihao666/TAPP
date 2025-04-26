import QtQuick 2.15

Item {
    id: generator
    property bool running: false
    property var coins: []

    property int spawnInterval: 1500
    property int lastSpawnTime: 0

    Timer {
        id: spawnTimer
        interval: 50
        running: generator.running
        repeat: true
        onTriggered: {
            var currentTime = new Date().getTime()
            if (currentTime - lastSpawnTime > spawnInterval) {
                spawnCoin()
                lastSpawnTime = currentTime
            }
        }
    }

    function spawnCoin() {
        var coin = coinComponent.createObject(generator.parent)
        coin.x = generator.parent.width
        coin.y = Math.random() * (generator.parent.height - 200) + 100
        coins.push(coin)
    }

    function removeCoin(coin) {
        var index = coins.indexOf(coin)
        if (index !== -1) {
            coins.splice(index, 1)
        }
        coin.destroy()
    }

    Component {
        id: coinComponent
        Rectangle {
            id: coin
            width: 30
            height: 30
            radius: width/2
            color: "gold"

            property int speed: 8

            Timer {
                interval: 16
                running: generator.running
                repeat: true
                onTriggered: {
                    coin.x -= speed
                    if (coin.x < -coin.width) {
                        generator.removeCoin(coin)
                    }
                }
            }
        }
    }
}
