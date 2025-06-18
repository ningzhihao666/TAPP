import QtQuick 2.15
import QtQuick.Controls 2.15
import NetworkManager 1.0

Page {
    id: battlePage
    property string targetIp
    property int targetPort

    GameScreen {
        id: gameScreen
        anchors.fill: parent
        isMultiplayer: true
        isLocalPlayer: true
    }

    Rectangle {
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

    Button {
        text: "断开连接"
        onClicked: {
            NetworkManager.disconnectFromHost();
            stackView.pop();
        }
    }

    Component.onCompleted: {
        console.log("原始IP:", targetIp);
        console.log("原始import:", targetPort);
        if (targetIp) {
            var realIp = targetIp.startsWith("::ffff:") ? targetIp.substring(7) : targetIp;

            // 输出连接参数信息
            console.log("正在尝试连接...");
            console.log("原始IP:", targetIp);
            console.log("处理后IP:", realIp);
            console.log("目标端口:", targetPort);

            NetworkManager.connectToHost(realIp, targetPort);
        } else {
            console.warn("targetIp为空，无法建立连接");
        }
    }
}


