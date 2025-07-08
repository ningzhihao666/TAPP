// BattleLobby.qml - 对战大厅页面
import QtQuick
import QtQuick.Controls
import QtQuick.Window

Page {
    id: battleLobby
    property var discoveredPeers: ListModel {}  //存放发现的房间
    property bool isHost: false  // 默认为客户端模式，创建房间时设为 true

    Image{
        source:"qrc:/page_begin/Images/page_begin/互联大厅页面.jpg"
        anchors.fill:parent
    }

    Column {
        height:Screen.height*0.8
        width:Screen.width*0.3
        anchors{
            left:parent.left;    leftMargin: Screen.width*0.05
            verticalCenter: parent.verticalCenter
        }

        spacing: parent.height*0.1

        Button {
            height:parent.height*0.15;  width:parent.width*0.6
            text: "创建房间"
            anchors.horizontalCenter: parent.horizontalCenter
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
            height:parent.height*0.15;  width:parent.width*0.6
            anchors.horizontalCenter: parent.horizontalCenter
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

        Button {
            text: "返回"
            height:parent.height*0.15;  width:parent.width*0.6
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: stackView.pop()
        }
    }

    Rectangle{
        width: Screen.width*0.6;  height: Screen.height*0.8
        radius:width*0.15;    border.width:Screen.height*0.05;    color:"transparent"
        border.color:"lightblue"
        anchors{
            right:parent.right
            rightMargin: Screen.width*0.05
            verticalCenter: parent.verticalCenter
        }

        Rectangle{
            id:liebiao;   color:"transparent"
            height:parent.height*0.1;   width:parent.width*0.4;  radius:width/8
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top:parent.top
            Label{ text:"房间列表";  color:"black";  anchors.centerIn: parent}
        }
        ListView {
            height:parent.height*0.9; width:parent.width
            anchors{
                top:liebiao.bottom
                horizontalCenter: parent.horizontalCenter
            }
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
