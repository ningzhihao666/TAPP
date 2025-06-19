#include <QTcpServer>
#include <QTcpSocket>
#include <QObject>
#include <QUdpSocket>
#include <QTimer>
#include <QNetworkInterface>
#include <QHostInfo>
#include <QHostAddress>
#include <QDataStream>
#include <QVariantMap>
#include <QAbstractSocket>
#include <qqmlintegration.h>
#include <QQmlEngine> // 添加这行
#include <QJSEngine>  // 添加这行

class NetworkManager : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    // 移除构造函数，改为静态实例获取方法
    static NetworkManager *instance();
    static NetworkManager *create(QQmlEngine *qmlEngine, QJSEngine *jsEngine);

    Q_INVOKABLE bool startServer(quint16 port);
    Q_INVOKABLE void connectToHost(const QString &ip, quint16 port);
    Q_INVOKABLE void sendGameData(const QVariantMap &data);
    Q_INVOKABLE void startBroadcasting();
    Q_INVOKABLE void stopBroadcasting();
    Q_INVOKABLE void discoverPeers();
    Q_INVOKABLE void disconnectFromHost();
    Q_PROPERTY(int socketState READ socketState NOTIFY socketStateChanged)
    Q_INVOKABLE void sendCommand(const QString &command);
    Q_INVOKABLE void sendGameState(const QVariantMap &state);
    Q_INVOKABLE void sendRandomSeed(quint32 seed);

signals:
    void socketStateChanged();
    void peerDiscovered(const QString &ip, const QString &name);
    void gameStateReceived(const QVariantMap &state);
    void opponentConnected();
    void gameDataReceived(const QVariantMap &data);
    void connectionError(const QString &msg);
    void isConnected();
    void serverStarted(quint16 port);
    void serverStartFailed(const QString &error);

    //游戏进行相关信号
    void gameStarted(); // 游戏开始信号
    void playerReady(); // 玩家准备信号

    void randomSeedReceived(quint32 seed); //使用随机种子来同步确保随机生成的障碍物等等都是生成的一样的位置

private slots:
    void readBroadcastDatagrams();
    void onNewConnection();
    void onClientDisconnected();
    void onDataReceived();

    void stopDiscovery(); // 声明发现资源清理方法

private:
    explicit NetworkManager(QObject *parent = nullptr);
    int socketState() const { return m_socket ? m_socket->state() : QAbstractSocket::UnconnectedState; }
    QUdpSocket *m_broadcastSocket;
    QUdpSocket *m_discoverSocket;
    QTimer *m_broadcastTimer;
    QString m_peerName;
    QTcpServer *m_server;
    QTcpSocket *m_socket;

    static NetworkManager *m_instance; // 静态实例指针
};
