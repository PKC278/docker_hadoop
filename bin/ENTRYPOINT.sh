#!/bin/bash
/usr/sbin/sshd
# 获取主机名
HOSTNAME=$(hostname)

# 如果主机名包含 "master"，则执行附加命令
if [[ "$HOSTNAME" == *"master"* ]]; then
    /usr/local/software/hadoop-3.3.5/sbin/start-all.sh
    echo "启动完成"
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
