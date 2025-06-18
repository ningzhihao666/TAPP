#include "NetworkManager.h"
#include <QTcpServer>
#include <QTcpSocket>

NetworkManager *NetworkManager::m_instance = nullptr;

NetworkManager::NetworkManager(QObject *parent) : QObject(parent)
{
    m_server = new QTcpServer(this);
    // 移除 broadcastSocket 的初始化，改为按需创建
    m_broadcastSocket = nullptr;
    m_broadcastTimer = nullptr;

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

    m_broadcastSocket = new QUdpSocket(this);
    // 绑定随机端口（发送不需要固定端口）
    if (!m_broadcastSocket->bind(QHostAddress::AnyIPv4, 0)) {
        qDebug() << "Broadcast bind failed:" << m_broadcastSocket->errorString();
        return;
    }

    // 获取本地 IP 和房间名
    QList<QHostAddress> localAddresses;
    foreach (const QHostAddress &address, QNetworkInterface::allAddresses()) {
        if (address.protocol() == QAbstractSocket::IPv4Protocol && address != QHostAddress::LocalHost) {
            localAddresses.append(address);
        }
    }

    localAddresses.append(QHostAddress("127.255.255.255")); // 添加回环广播

    QString roomInfo = "房间已创建:\n";
    foreach (const QHostAddress &address, localAddresses) {
        roomInfo += "IP: " + address.toString() + "\n";
    }
    roomInfo += "端口: 54321";
    emit serverStarted(54321); // 触发 UI 更新
    qDebug() << roomInfo;
    qDebug() << "可用网络接口：";
    foreach (const QNetworkInterface &interface, QNetworkInterface::allInterfaces()) {
        qDebug() << "接口:" << interface.name() << "IP:";
        foreach (const QNetworkAddressEntry &entry, interface.addressEntries()) {
            if (!entry.ip().isLoopback() && entry.ip().protocol() == QAbstractSocket::IPv4Protocol) {
                qDebug() << "  " << entry.ip().toString() << "广播地址:" << entry.broadcast().toString();
            }
        }
    }

    // 定时广播
    m_broadcastTimer = new QTimer(this);
    connect(m_broadcastTimer, &QTimer::timeout, this, [this]() {
        QByteArray datagram = "TTKP:" + QHostInfo::localHostName().toUtf8();
        m_broadcastSocket->writeDatagram(datagram, QHostAddress::Broadcast, 45454);
    });
    m_broadcastTimer->start(1000);
}
void NetworkManager::stopBroadcasting()
{
    if (m_broadcastTimer) {
        m_broadcastTimer->stop();
        m_broadcastTimer->deleteLater();
        m_broadcastTimer = nullptr;
    }

    if (m_broadcastSocket) {
        m_broadcastSocket->close();
        m_broadcastSocket->deleteLater();
        m_broadcastSocket = nullptr;
    }
}

void NetworkManager::stopDiscovery()
{
    if (m_discoverSocket) {
        m_discoverSocket->close();
        m_discoverSocket->deleteLater();
        m_discoverSocket = nullptr;
    }
}
void NetworkManager::discoverPeers()
{
    m_discoverSocket = new QUdpSocket(this);
    if (!m_discoverSocket->bind(45454, QUdpSocket::ShareAddress)) {
        emit connectionError("发现绑定失败: " + m_discoverSocket->errorString());
        return;
    }
    connect(m_discoverSocket, &QUdpSocket::readyRead, this, &NetworkManager::readBroadcastDatagrams);
}
void NetworkManager::readBroadcastDatagrams()
{
    while (m_discoverSocket->hasPendingDatagrams()) {
        QByteArray datagram;
        datagram.resize(m_discoverSocket->pendingDatagramSize());
        QHostAddress senderIp;
        quint16 senderPort;

        m_discoverSocket->readDatagram(datagram.data(), datagram.size(), &senderIp, &senderPort);

        if (datagram.startsWith("TTKP:")) {
            QString roomName = QString::fromUtf8(datagram.mid(5));
            emit peerDiscovered(senderIp.toString(), roomName);
        }
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
