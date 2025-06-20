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
    qDebug() << "=== 开始连接诊断 ===";
    qDebug() << "目标地址:" << ip << "端口:" << port;

    // 打印本机所有网络接口
    qDebug() << "可用网络接口:";
    foreach (const QNetworkInterface &interface, QNetworkInterface::allInterfaces()) {
        qDebug() << "接口:" << interface.name();
        foreach (const QNetworkAddressEntry &entry, interface.addressEntries()) {
            qDebug() << "  IP:" << entry.ip().toString() << "广播地址:" << entry.broadcast().toString();
        }
    }

    // 清理旧连接（增强版）
    if (m_socket) {
        qDebug() << "清理现有连接...";
        disconnect(m_socket, nullptr, this, nullptr);
        m_socket->abort();
        m_socket->deleteLater();
        m_socket = nullptr;
    }

    m_socket = new QTcpSocket(this);
    qDebug() << "Socket对象已创建:" << m_socket;
    connect(m_socket, &QTcpSocket::readyRead, this, &NetworkManager::onDataReceived);

    // 连接状态信号（调试用）
    connect(m_socket, &QTcpSocket::stateChanged, this, [this](QAbstractSocket::SocketState state) {
        qDebug() << "[状态变更] ->" << state;
        emit socketStateChanged(); // 新增这行
    });

    // 核心信号连接
    connect(m_socket, &QTcpSocket::connected, this, [this]() {
        qDebug() << "!!! 连接成功 !!! 对端地址:" << m_socket->peerAddress();
        emit opponentConnected();
    });

    // 增强错误处理
    connect(m_socket,
            QOverload<QAbstractSocket::SocketError>::of(&QTcpSocket::errorOccurred),
            this,
            [this](QAbstractSocket::SocketError error) {
                qDebug() << "[错误详情] 代码:" << error << "描述:" << m_socket->errorString();
                emit connectionError(m_socket->errorString());
            });
    // 避免端口冲突（尤其在同一台机器测试时）
    if (!m_socket->bind(QHostAddress::Any, 0)) { // 0 表示随机端口
        qDebug() << "客户端端口绑定失败:" << m_socket->errorString();
    }

    // 开始连接
    qDebug() << "尝试建立连接...";
    m_socket->connectToHost(QHostAddress(ip), port);

    // 超时检测（带状态记录）
    QTimer::singleShot(3000, this, [this, ip, port]() {
        if (m_socket && m_socket->state() == QAbstractSocket::ConnectingState) {
            qDebug() << "超时中止！当前状态:" << m_socket->state();
            m_socket->abort();
            emit connectionError("连接超时");
        }
    });
}

void NetworkManager::sendGameData(const QVariantMap &data)
{
    if (m_socket && m_socket->state() == QAbstractSocket::ConnectedState) {
        // 获取本地（发送者）和远程（接收者）的IP和端口
        //QString localAddress = m_socket->localAddress().toString();
        //quint16 localPort = m_socket->localPort();
        //QString peerAddress = m_socket->peerAddress().toString();
        //quint16 peerPort = m_socket->peerPort();

        // 输出发送详情
        //qDebug() << "=== 数据发送详情 ===";
        //qDebug() << "发送者:" << localAddress << ":" << localPort;
        //qDebug() << "接收者:" << peerAddress << ":" << peerPort;
        //qDebug() << "数据内容:" << data; // 输出 QVariantMap 内容
        // qDebug() << "===================";

        // 序列化并发送数据
        QByteArray buffer;
        QDataStream stream(&buffer, QIODevice::WriteOnly);
        stream << data;
        m_socket->write(buffer);

        // 可选：输出字节流的16进制格式（用于二进制调试）
        qDebug() << "原始字节流(hex):" << buffer.toHex();
    } else {
        qDebug() << "发送失败：Socket未连接或无效";
    }
}
void NetworkManager::onNewConnection()
{
    m_socket = m_server->nextPendingConnection();

    // 关键判断：检查套接字状态是否为已连接
    if (m_socket->state() == QTcpSocket::ConnectedState) {
        qDebug() << "TCP连接已确认建立 | 客户端IP:" << m_socket->peerAddress().toString()
                 << "端口:" << m_socket->peerPort();

        connect(m_socket, &QTcpSocket::readyRead, this, &NetworkManager::onDataReceived);
        emit opponentConnected(); // 通知UI连接成功
    } else {
        qDebug() << "警告：套接字未处于连接状态 | 当前状态:" << m_socket->state();
        m_socket->deleteLater(); // 清理无效连接
    }
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

//游戏进行相关信号
// 在onDataReceived中添加处理逻辑
void NetworkManager::sendCommand(const QString &command)
{
    if (m_socket && m_socket->state() == QAbstractSocket::ConnectedState) {
        QVariantMap data;
        data["command"] = command;

        // 获取本地（发送者）和远程（接收者）的IP和端口
        QString localAddress = m_socket->localAddress().toString();
        quint16 localPort = m_socket->localPort();
        QString peerAddress = m_socket->peerAddress().toString();
        quint16 peerPort = m_socket->peerPort();

        // 输出发送者和接收者信息
        qDebug() << "=== 命令发送详情 ===";
        qDebug() << "发送者:" << localAddress << ":" << localPort;
        qDebug() << "接收者:" << peerAddress << ":" << peerPort;
        qDebug() << "命令内容:" << command;
        qDebug() << "===================";

        sendGameData(data); // 发送数据
    }
}

void NetworkManager::onDataReceived()
{
    qDebug() << "正在收取命令----------------------------------------------";
    if (!m_socket || m_socket->state() != QAbstractSocket::ConnectedState) { return; }

    QDataStream stream(m_socket);
    stream.setVersion(QDataStream::Qt_5_15); // 确保版本一致

    while (m_socket->bytesAvailable() > 0) {
        // 检查是否有足够的数据（防止半包）
        if (m_socket->bytesAvailable() < sizeof(quint32)) { return; }

        // 尝试读取数据
        QVariantMap data;
        stream >> data;

        if (stream.status() != QDataStream::Ok) {
            qDebug() << "数据流读取错误！";
            return;
        }
        qDebug() << "接收到数据:" << data;
        // 处理命令
        if (data.contains("command")) {
            QString cmd = data["command"].toString();
            if (cmd == "ready") {
                emit playerReady();
            } else if (cmd == "start") {
                emit gameStarted();
            }
        } // 处理游戏状态
        else if (data.contains("playerX") && data.contains("playerY")) {
            emit gameStateReceived(data);
        } else if (data.contains("type") && data["type"] == "seed") {
            quint32 seed = data["seed"].toUInt();
            emit randomSeedReceived(seed);
        }
    }
}

void NetworkManager::sendRandomSeed(quint32 seed)
{
    if (m_socket) {
        QVariantMap data;
        data["type"] = "seed";
        data["seed"] = seed;
        QByteArray buffer;
        QDataStream stream(&buffer, QIODevice::WriteOnly);
        stream << data; // 序列化
        m_socket->write(buffer);
        qDebug() << "已发送随机种子:" << seed;
    }
}
