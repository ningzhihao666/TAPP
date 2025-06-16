import QtQuick
import QtQuick.Controls
import QtQuick.Window

ApplicationWindow {
    id: window
    width: Screen.width
    height: Screen.height
    visible: true
    flags:Qt.Window | Qt.MaximizeUsingFullscreenGeometryHint
    visibility: Window.FullScreen

    title: "天天跑酷"

    StackView {
        id: stackView
        initialItem: mainMenu
        anchors.fill: parent
    }

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
