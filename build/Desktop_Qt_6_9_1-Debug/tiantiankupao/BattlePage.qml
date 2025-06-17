import QtQuick 2.15
import QtQuick.Controls 2.15
import NetworkManager 1.0

Page {
    id: battlePage
    property string targetIp: ""
    property int targetPort: 54321

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
        if (targetIp) {
            NetworkManager.connectToHost(targetIp, targetPort);
        }
    }
}


