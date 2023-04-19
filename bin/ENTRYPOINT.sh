#!/bin/bash
/usr/sbin/sshd
# 获取主机名
HOSTNAME=$(hostname)

# 如果主机名包含 "master"，则执行附加命令
if [[ "$HOSTNAME" == *"master"* ]]; then
    echo "0" > /usr/local/software/zookeeper-3.7.1/datadir/myid
    /root/bin/zk start
    /usr/local/software/hadoop-3.3.5/sbin/start-all.sh
    /usr/local/software/hbase-2.4.17/bin/start-hbase.sh
    echo "启动完成"
fi
if [[ "$HOSTNAME" == *"slave1"* ]]; then
    echo "1" > /usr/local/software/zookeeper-3.7.1/datadir/myid
fi
if [[ "$HOSTNAME" == *"slave2"* ]]; then
    echo "2" > /usr/local/software/zookeeper-3.7.1/datadir/myid
fi

# 定义一个函数，用于在接收到SIGTERM或SIGINT时执行清理操作
function cleanup {
    echo "收到关闭信号，正在退出..."
    # 在此处添加您的清理逻辑，例如保存文件等
    # 如果主机名包含 "master"，则执行附加命令
    if [[ "$HOSTNAME" == *"master"* ]]; then
        /usr/local/software/hadoop-3.3.5/sbin/stop-all.sh
    fi
    exit 0
}

# 在接收到SIGTERM或SIGINT时执行cleanup函数
trap cleanup SIGTERM SIGINT

# 无限循环
while true
do
    echo "Docker容器正在运行..." > /dev/null
done
