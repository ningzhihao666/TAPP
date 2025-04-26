//Player.qml    角色逻辑判定
import QtQuick
import QtQuick.Controls
import QtQuick.Window

Item {
    id: player
    width: Screen.width/12
    height: Screen.height/7

    property bool jumping: false
    property bool sliding: false

    Image {
        source: "qrc:/player/Images/player/哥玛兽.png"
        anchors.fill: parent
    }

    // 跳跃动画
    SequentialAnimation on y {
        id: jumpAnimation
        running: false
        NumberAnimation {
            from: player.y
            to: player.y - 150
            duration: 300
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            from: player.y - 150
            to: player.y
            duration: 300
            easing.type: Easing.InQuad
        }
        onFinished: jumping = false
    }

    // 滑动动画
    ParallelAnimation {
        id: slideAnimation
        running: false
        NumberAnimation {
            target: player
            property: "height"
            from: 80
            to: 40
            duration: 200
        }
        NumberAnimation {
            target: player
            property: "y"
            from: player.y
            to: player.y + 40
            duration: 200
        }
        onFinished: {
            sliding = false
            player.height = 80
            player.y = player.y - 40
        }
    }

    function jump() {
        if (!jumping && !sliding) {
            jumping = true
            jumpAnimation.start()
        }
    }

    function slide() {
        if (!jumping && !sliding) {
            sliding = true
            slideAnimation.start()
        }
    }
}
