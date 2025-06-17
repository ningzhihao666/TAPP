#include "NetworkManager.h"
#include <QTcpServer>
#include <QTcpSocket>

NetworkManager *NetworkManager::m_instance = nullptr;

NetworkManager::NetworkManager(QObject *parent) : QObject(parent)
{
    m_server = new QTcpServer(this);
    /// 移除 broadcastSocket 的初始化，改为按需创建
    broadcastSocket = nullptr;
    broadcastTimer = nullptr;

    connect(m_server, &QTcpServer::newConnection, this, &NetworkManager::onNewConnection);
}
NetworkManager *NetworkManager::instance()
{
    if (!m_instance) { m_instance = new NetworkManager(); }
    return m_instance;
}

NetworkManager *NetworkManager::create(QQmlEngine *qmlEngine, QJSEngine *jsEngine)
{
    Q_UNUSED(qmlEngine)
    Q_UNUSED(jsEngine)
    return instance();
}

void NetworkManager::disconnectFromHost()
{
    if (m_socket) {
        m_socket->disconnectFromHost();
        if (m_socket->state() == QAbstractSocket::ConnectedState) { m_socket->waitForDisconnected(1000); }
        m_socket->deleteLater();
        m_socket = nullptr;
    }

    // 停止广播
    stopBroadcasting();

    emit connectionError("主动断开连接");
}
bool NetworkManager::startServer(quint16 port)
{
    // 确保服务器未在运行
    if (m_server->isListening()) { m_server->close(); }

    if (!m_server->listen(QHostAddress::Any, port)) {
        QString error = "服务器启动失败: " + m_server->errorString();
        qDebug() << error;
        emit serverStartFailed(error);
        return false;
    }

    qDebug() << "服务器已启动，监听端口:" << port;
    emit serverStarted(port);
    return true;
}

void NetworkManager::connectToHost(const QString &ip, quint16 port)
{
    if (m_socket) {
        m_socket->disconnectFromHost();
        m_socket->deleteLater();
        m_socket = nullptr;
    }

    m_socket = new QTcpSocket(this);

    // 连接所有必要信号
    connect(m_socket, &QTcpSocket::connected, this, &NetworkManager::opponentConnected);
    connect(m_socket, &QTcpSocket::readyRead, this, &NetworkManager::onDataReceived);
    connect(m_socket, &QTcpSocket::disconnected, this, &NetworkManager::onClientDisconnected);
    connect(m_socket,
            QOverload<QAbstractSocket::SocketError>::of(&QTcpSocket::errorOccurred),
            this,
            [this](QAbstractSocket::SocketError error) {
                emit connectionError("连接错误: " + m_socket->errorString());
            });

    qDebug() << "尝试连接到:" << ip << ":" << port;
    m_socket->connectToHost(QHostAddress(ip), port);

    // 添加连接超时检测
    QTimer::singleShot(3000, this, [this, ip, port]() {
        if (m_socket && m_socket->state() == QAbstractSocket::ConnectingState) {
            m_socket->abort();
            emit connectionError("连接超时: " + ip + ":" + QString::number(port));
        }
    });
}

void NetworkManager::sendGameData(const QVariantMap &data)
{
    if (m_socket && m_socket->state() == QAbstractSocket::ConnectedState) {
        QByteArray buffer;
        QDataStream stream(&buffer, QIODevice::WriteOnly);
        stream << data;
        m_socket->write(buffer);
    }
}

void NetworkManager::onNewConnection()
{
    m_socket = m_server->nextPendingConnection();
    connect(m_socket, &QTcpSocket::readyRead, this, &NetworkManager::onDataReceived);
    emit opponentConnected();
}

void NetworkManager::onClientDisconnected()
{
    qDebug() << "Connection lost, attempting to reconnect...";
    if (m_socket) { m_socket->connectToHost(m_socket->peerAddress(), m_socket->peerPort()); }
}
// NetworkManager.cpp 新增部分

void NetworkManager::startBroadcasting()
{
    stopBroadcasting();

    broadcastSocket = new QUdpSocket(this);
    broadcastTimer = new QTimer(this);

    // 输出房间信息
    QList<QHostAddress> localAddresses;
    foreach (const QHostAddress &address, QNetworkInterface::allAddresses()) {
        if (address.protocol() == QAbstractSocket::IPv4Protocol && address != QHostAddress::LocalHost) {
            localAddresses.append(address);
        }
    }

    qDebug() << "Room created with the following IP addresses:";
    foreach (const QHostAddress &address, localAddresses) {
        qDebug() << "IP:" << address.toString() << "Port:" << 54321;
    }

    // 绑定 UDP 端口
    if (!broadcastSocket->bind(45454, QUdpSocket::ShareAddress | QUdpSocket::ReuseAddressHint)) {
        qDebug() << "Failed to bind UDP socket for broadcasting:" << broadcastSocket->errorString();
        return;
    }

    // 获取广播地址
    QList<QHostAddress> broadcastAddresses;
    foreach (const QNetworkInterface &interface, QNetworkInterface::allInterfaces()) {
        foreach (const QNetworkAddressEntry &entry, interface.addressEntries()) {
            if (!entry.broadcast().isNull() && interface.flags().testFlag(QNetworkInterface::CanBroadcast)) {
                broadcastAddresses.append(entry.broadcast());
                qDebug() << "Broadcasting to:" << entry.broadcast().toString();
            }
        }
    }

    peerName = QHostInfo::localHostName();

    connect(broadcastTimer, &QTimer::timeout, this, [this, broadcastAddresses]() {
        QByteArray datagram = "TTKP:" + peerName.toUtf8();
        foreach (const QHostAddress &address, broadcastAddresses) {
            broadcastSocket->writeDatagram(datagram, address, 45454);
        }
    });

    broadcastTimer->start(1000);
    qDebug() << "Broadcasting started...";
}
void NetworkManager::stopBroadcasting()
{
    if (broadcastTimer) {
        broadcastTimer->stop();
        broadcastTimer->deleteLater();
        broadcastTimer = nullptr;
    }

    if (broadcastSocket) {
        broadcastSocket->close();
        broadcastSocket->deleteLater();
        broadcastSocket = nullptr;
    }
}

void NetworkManager::discoverPeers()
{
    qDebug() << "discoverPeers called. broadcastSocket pointer:" << broadcastSocket;

    if (!broadcastSocket) {
        qDebug() << "Creating new UDP socket...";
        broadcastSocket = new QUdpSocket(this);
    } else {
        qDebug() << "Socket already exists. State:" << broadcastSocket->state();
    }
    if (!broadcastSocket) {
        broadcastSocket = new QUdpSocket(this);
        // 先断开之前的连接
        disconnect(broadcastSocket, &QUdpSocket::readyRead, this, &NetworkManager::readBroadcastDatagrams);
        // 重新连接信号
        connect(broadcastSocket, &QUdpSocket::readyRead, this, &NetworkManager::readBroadcastDatagrams);
    }

    // 先关闭之前的绑定
    broadcastSocket->close();

    if (!broadcastSocket->bind(45454, QUdpSocket::ShareAddress | QUdpSocket::ReuseAddressHint)) {
        qDebug() << "Failed to bind UDP socket for discovery:" << broadcastSocket->errorString();
        emit connectionError("绑定UDP端口失败: " + broadcastSocket->errorString());
        // 添加错误处理，防止崩溃
        broadcastSocket->deleteLater();
        broadcastSocket = nullptr;
        return;
    }

    qDebug() << "UDP socket bound successfully for discovery";
}
void NetworkManager::readBroadcastDatagrams()
{
    if (!broadcastSocket || !broadcastSocket->hasPendingDatagrams()) return;

    try {
        while (broadcastSocket->hasPendingDatagrams()) {
            QByteArray datagram;
            datagram.resize(broadcastSocket->pendingDatagramSize());
            QHostAddress senderIp;
            quint16 senderPort;

            qint64 bytesRead = broadcastSocket->readDatagram(datagram.data(), datagram.size(), &senderIp, &senderPort);

            if (bytesRead == -1) {
                qDebug() << "读取数据报失败:" << broadcastSocket->errorString();
                continue;
            }

            if (datagram.startsWith("TTKP:")) {
                QString peerName = QString::fromUtf8(datagram.mid(5));
                if (senderIp != QHostAddress::LocalHost) { emit peerDiscovered(senderIp.toString(), peerName); }
            }
        }
    } catch (...) {
        qCritical() << "处理UDP数据时发生异常";
    }
}
// NetworkManager.cpp 新增
void NetworkManager::sendGameState(const QVariantMap &state)
{
    if (m_socket && m_socket->state() == QAbstractSocket::ConnectedState) {
        QByteArray buffer;
        QDataStream stream(&buffer, QIODevice::WriteOnly);
        stream << state;
        m_socket->write(buffer);
    }
}

// 修改原有的onDataReceived处理
void NetworkManager::onDataReceived()
{
    QDataStream stream(m_socket);
    QVariantMap data;
    stream >> data;
    if (data.contains("gameState")) {
        emit gameStateReceived(data["gameState"].toMap());
    } else {
        emit gameDataReceived(data);
    }
}
