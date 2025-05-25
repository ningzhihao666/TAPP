#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QSettings>


int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    //设置组织名称和域名
    QCoreApplication::setOrganizationName("cqnu");
    QCoreApplication::setOrganizationDomain("cqnu.com");
    QCoreApplication::setApplicationName("天天酷跑");

    QQmlApplicationEngine engine;
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, []() { QCoreApplication::exit(-1); }, Qt::QueuedConnection);

    engine.loadFromModule("tiantiankupao", "Main");

    return app.exec();
}
