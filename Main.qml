import QtQuick
import QtQuick.Controls
import QtQuick.Window

ApplicationWindow {
    id: window
    width: Screen.width
    height: Screen.height
    visible: true
    title: "天天跑酷"

    StackView {
        id: stackView
        initialItem: mainMenu
        anchors.fill: parent
    }

    //开始菜单
    Component {
        id: mainMenu
        MainMenu {}
    }

    //游戏屏幕
    Component {
        id: gameScreen
        GameScreen {}
    }
}
