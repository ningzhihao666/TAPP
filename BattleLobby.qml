// BattleLobby.qml - 对战大厅页面
import QtQuick
import QtQuick.Controls
import NetworkManager 1.0  // 确保导入路径与注册时一致

Page {
    id: battleLobby
    property var discoveredPeers: ListModel {}
    property bool isHost: false  // 默认为客户端模式，创建房间时设为 true

    Image{
        source:"qrc:/page_begin/Images/page_begin/互联大厅页面.jpg"
        anchors.fill:parent
    }

    Column {
        anchors.centerIn: parent
        spacing: 20

        Button {
            text: "创建房间"
            onClicked: {
                try {
                    // 先启动服务器
                    if (NetworkManager.startServer(54321)) {
                        // 服务器启动成功后再开始广播
                        statusText.text = "房间创建成功...";
                        NetworkManager.startBroadcasting()
                        isHost=true
                        stackView.push("BattlePage.qml", {
                            "isHost":isHost
                        })
                    } else {
                        console.error("服务器启动失败")
                    }
                } catch (e) {
                    console.error("创建房间失败:", e)
                }
            }
        }

        Button {
            text: "搜索房间"
            onClicked: {
                statusText.text = "正在搜索房间..."
                try {
                    NetworkManager.discoverPeers();
                    // 添加超时处理
                    searchTimer.start();
                } catch (e) {
                    console.error("崩溃原因:", e);
                    statusText.text = "搜索失败: " + e
                }
            }
        }
        Text {
            id: statusText
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Timer {
            id: searchTimer
            interval: 5000 // 5秒超时
            onTriggered: {
                if (discoveredPeers.count === 0) {
                    statusText.text = "未发现任何房间"
                }
            }
        }

        ListView {
            width: 300
            height: 200
            model: discoveredPeers
            delegate: Button {
                width: parent.width
                text: model.name + " (" + model.ip + ")"
                onClicked: {
                    stackView.push("BattlePage.qml", {
                        "targetIp": model.ip,
                        "targetPort": 54321,
                        "isHost":isHost
                    })
                }
            }
        }

        Button {
            text: "返回"
            onClicked: stackView.pop()
        }
    }

    Connections {
        target: NetworkManager

        function onConnectionError(msg) {
            console.error("网络错误:", msg);
            statusText.text = "错误: " + msg;
            statusText.color = "red";
        }

        function onServerStarted(port) {
            console.log("服务器已启动，端口:", port);
            statusText.text = "房间创建成功(端口:" + port + ")";
            statusText.color = "green";
        }

        function onServerStartFailed(error) {
            console.error("服务器启动失败:", error);
            statusText.text = "创建房间失败: " + error;
            statusText.color = "red";
        }
        function onPeerDiscovered(ip, name) {
            if (ip.startsWith("::ffff:")) {
                   ip = ip.substring(7); // 提取172.20.10.2部分
               }
            console.log("发现房间:", ip, name);
            var exists = false;
                    for (var i = 0; i < discoveredPeers.count; ++i) {
                        if (discoveredPeers.get(i).ip === ip) {
                            exists = true;
                            break;
                        }
                    }
                    // 如果是新房间则添加到列表
                    if (!exists) {
                        discoveredPeers.append({"ip": ip, "name": name});
                        statusText.text = "发现新房间: " + name;
                    }
                }
}

}
