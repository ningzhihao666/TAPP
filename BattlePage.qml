import QtQuick
import QtQuick.Controls
import NetworkManager 1.0


Page {
    id: battlePage
    property string targetIp:""
    property int targetPort:0
    property bool isHost:false
    property bool isReady: false
    property bool opponentReady: false
    property bool isWinner: false
    property int playerDistance: 0
    property int opponentDistance: 0


    GameScreen {
        id: gameScreen
        anchors.fill: parent
        isMultiplayer: true
        isLocalPlayer: true
        visible: false // 初始不可见
    }

    // 连接状态显示
    Rectangle {
        id: connectionStatus
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: 200
        height: 40
        color: NetworkManager.socketState === 3 ? "green" : "red"
        Text {
            anchors.centerIn: parent
            text: NetworkManager.socketState === 3 ? "已连接" : "未连接"
        }
    }

    // 准备/开始按钮区域
    Column {
        anchors.centerIn: parent
        spacing: 20
        visible: !gameScreen.visible // 游戏开始后隐藏

        Button {
            id: readyButton
            text: isReady ? "取消准备" : "准备"
            onClicked: {
                isReady = !isReady;
                NetworkManager.sendCommand(isReady ? "ready" : "unready");
            }
        }

        Button {
            id: startButton
            text: "开始比赛"
            visible: isHost
            enabled: isReady && opponentReady
            onClicked: {
                // 如果是房主，先发送随机种子
                if (isHost) {
                    var seed = Math.floor(Math.random() * 1000000);
                    gameScreen.setRandomSeed(seed);
                    NetworkManager.sendRandomSeed(seed);
                }
                // 然后发送开始命令
                NetworkManager.sendCommand("start");
                gameScreen.startGame(); // 直接调用，避免依赖网络信号
            }
        }

        Text {
            text: opponentReady ? "对手已准备" : "等待对手准备..."
            color: "white"
        }
    }

    Button {
        text: "断开连接"
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        onClicked: {
            NetworkManager.disconnectFromHost();
            stackView.pop();
        }
    }

    Dialog {
        id: multiplayerResultDialog
        height: Screen.height*3/5
        width: Screen.width*3/5
        anchors.centerIn: parent
        title: "对战结果"
        modal: true
        closePolicy: Popup.NoAutoClose

        Image {
            source: "qrc:/BackGround/Images/BackGround/暂停面板背景.jpg"
            anchors.fill: parent
        }

        Column {
            anchors.centerIn: parent
            spacing: 20

            Label {
                text: isWinner ? "胜利!" : "失败!"
                color: isWinner ? "gold" : "red"
                font.pixelSize: 48
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Label {
                text: "你的距离: " + (playerDistance/16).toFixed(1) + " 米"
                font.pixelSize: 24
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Label {
                text: "对手距离: " + (opponentDistance/16).toFixed(1) + " 米"
                font.pixelSize: 24
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Rectangle {
            height: parent.height*0.2
            width: parent.width*0.5
            radius: height/2
            color: "lightgreen"
            anchors {
                bottom: parent.bottom
                bottomMargin: parent.height*0.1
                horizontalCenter: parent.horizontalCenter
            }

            Button {
                anchors.fill: parent
                background: Rectangle { color: "transparent" }
                Label {
                    text: "返回大厅"
                    color: "black"
                    anchors.centerIn: parent
                }
                onClicked: {
                    multiplayerResultDialog.close()
                    stackView.pop()
                }
            }
        }
    }

    Connections {
        target: NetworkManager
        function onPlayerReady() {
            opponentReady = true;
            if (isHost && isReady) {
                startButton.enabled = true;
            }
        }
        function onOpponentConnected() {
               console.log("服务端确认连接成功！"); // 检查是否触发
               connectionStatus.color = "green"; // 更新UI
               connectionStatus.children[0].text="已连接";

           }

        function onGameStarted() {  //疑似未触发
                console.log("游戏开始信号已接收");
                gameScreen.visible = true;
                gameScreen.startGame();
            }

        function onSocketStateChanged() {
                if (NetworkManager.socketState !== 3) { // 如果不是已连接状态
                    stackView.pop(); // 返回上一页
                }
            }
        function onRandomSeedReceived(seed) {
                console.log("接收到随机种子:", seed);
                if (!isHost) {
                    gameScreen.setRandomSeed(seed);
                }
            }
        function onPlayerDefeated() {
               console.log("收到对手失败通知");
               showMultiplayerResult(true); // true表示胜利
           }

           function onVictoryAchieved() {
               console.log("收到对手胜利通知");
               showMultiplayerResult(false); // false表示失败
           }
    }

    Component.onCompleted: {
        if (!isHost && targetIp) {
            var realIp = targetIp.startsWith("::ffff:") ? targetIp.substring(7) : targetIp;
             //console.log(":-------------------------", realIp);
            NetworkManager.connectToHost(realIp, targetPort);
        }
    }
}
