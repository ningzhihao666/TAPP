#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QSettings>
#include <QQmlContext>
#include <QScopedPointer>
#include <QDebug>
#include "NetworkManager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // 应用信息设置
    QCoreApplication::setOrganizationName("cqnu");
    QCoreApplication::setOrganizationDomain("cqnu.com");
    QCoreApplication::setApplicationName("天天酷跑");

    QQmlApplicationEngine engine;

    // 添加导入路径 - 确保包含网络模块
    engine.addImportPath("build/network_module");
    engine.addImportPath(QCoreApplication::applicationDirPath());

    // 注册单例实例
    qmlRegisterSingletonInstance("NetworkManager", 1, 0, "NetworkManager", NetworkManager::instance());

    // 调试输出导入路径
    qDebug() << "Import paths:" << engine.importPathList();

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, []() { QCoreApplication::exit(-1); }, Qt::QueuedConnection);

    engine.loadFromModule("tiantiankupao", "Main");

    return app.exec();
}
