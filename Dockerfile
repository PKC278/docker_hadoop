FROM centos:centos7
RUN yum update -y \
    && yum install -y rsync wget tar which net-tools openssh-clients openssh-server passwd openssl kde-l10n-Chinese sudo \
    && mkdir -p /usr/local/software \
    && mkdir -p /root/.ssh \
    && wget -O /tmp/hbase.tar.gz https://dlcdn.apache.org/hbase/2.4.17/hbase-2.4.17-bin.tar.gz \
    && wget -O /tmp/zookeeper.tar.gz https://dlcdn.apache.org/zookeeper/zookeeper-3.7.1/apache-zookeeper-3.7.1-bin.tar.gz \
    && wget -O /tmp/hive.tar.gz https://dlcdn.apache.org/hive/hive-3.1.3/apache-hive-3.1.3-bin.tar.gz \
    && wget -O /tmp/mysql.rpm https://dev.mysql.com/get/mysql80-community-release-el7-7.noarch.rpm \
    && rpm -ivh /tmp/mysql.rpm \
    && yum update -y \
    && yum install -y mysql-community-client \
    && yum clean all \
    && if [ "$(uname -m)" = "aarch64" ]; then \
    wget -O /tmp/s6-overlay-noarch.tar.xz https://github.com/just-containers/s6-overlay/releases/download/v3.1.4.2/s6-overlay-noarch.tar.xz  && \
    wget -O /tmp/s6-overlay.tar.xz https://github.com/just-containers/s6-overlay/releases/download/v3.1.4.2/s6-overlay-aarch64.tar.xz  && \
    wget -O /tmp/jdk.tar.gz https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u372-b07/OpenJDK8U-jdk_aarch64_linux_hotspot_8u372b07.tar.gz && \
    wget -O /tmp/hadoop.tar.gz https://dlcdn.apache.org/hadoop/common/hadoop-3.3.5/hadoop-3.3.5-aarch64.tar.gz ; \
    elif [ "$(uname -m)" = "x86_64" ]; then \
    wget -O /tmp/s6-overlay-noarch.tar.xz https://github.com/just-containers/s6-overlay/releases/download/v3.1.4.2/s6-overlay-noarch.tar.xz  && \
    wget -O /tmp/s6-overlay.tar.xz https://github.com/just-containers/s6-overlay/releases/download/v3.1.4.2/s6-overlay-x86_64.tar.xz  && \
    wget -O /tmp/jdk.tar.gz https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u372-b07/OpenJDK8U-jdk_x64_linux_hotspot_8u372b07.tar.gz && \
    wget -O /tmp/hadoop.tar.gz https://dlcdn.apache.org/hadoop/common/hadoop-3.3.5/hadoop-3.3.5.tar.gz ; \
    fi

WORKDIR /root
COPY bin /tmp/

RUN mv /tmp/bin /root/ \
    && mv /tmp/ssh_key/* /etc/ssh/ \
    && mv /tmp/ssh/* /root/.ssh/ \
    && tar -zxvf /tmp/jdk.tar.gz -C /usr/local/software/ > /dev/null \
    && tar -zxvf /tmp/hadoop.tar.gz -C /usr/local/software/ > /dev/null \
    && tar -zxvf /tmp/hbase.tar.gz -C /usr/local/software/ > /dev/null \
    && tar -zxvf /tmp/zookeeper.tar.gz -C /usr/local/software/ > /dev/null \
    && tar -zxvf /tmp/hive.tar.gz -C /usr/local/software/ > /dev/null \
    && mv /usr/local/software/apache-hive-3.1.3-bin/ /usr/local/software/hive-3.1.3 \
    && tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz > /dev/null \
    && tar -C / -Jxpf /tmp/s6-overlay.tar.xz > /dev/null \
    && mv /usr/local/software/apache-zookeeper-3.7.1-bin/ /usr/local/software/zookeeper-3.7.1 \
    && mv /tmp/hadoop/* /usr/local/software/hadoop-3.3.5/etc/hadoop/ \
    && mv /tmp/sbin/* /usr/local/software/hadoop-3.3.5/sbin/ \
    && mv /tmp/hbase/* /usr/local/software/hbase-2.4.17/conf/ \
    && mv /tmp/Zookeeper/* /usr/local/software/zookeeper-3.7.1/conf \
    && mv /tmp/hive/* /usr/local/software/hive-3.1.3/conf \
    && mv /tmp/s6-rc.d/hadoop /etc/s6-overlay/s6-rc.d/ \
    && touch /etc/s6-overlay/s6-rc.d/user/contents.d/hadoop \
    && mkdir -p /usr/local/software/hbase-2.4.17/data/tmp \
    && mkdir -p /usr/local/software/zookeeper-3.7.1/datadir \
    && mkdir -p /usr/local/software/zookeeper-3.7.1/log \
    && touch /usr/local/software/zookeeper-3.7.1/datadir/myid \
    && cp /usr/local/software/hadoop-3.3.5/etc/hadoop/hdfs-site.xml /usr/local/software/hbase-2.4.17/conf/ \
    && rm -rf /tmp/* \
    && echo 'export PATH=$PATH:/root/bin' | sudo tee -a /etc/profile \
    && echo 'export JAVA_HOME=/usr/local/software/jdk8u372-b07' | sudo tee -a /etc/profile \
    && echo 'export PATH=$PATH:$JAVA_HOME/bin' | sudo tee -a /etc/profile \
    && echo 'export HADOOP_HOME=/usr/local/software/hadoop-3.3.5' | sudo tee -a /etc/profile \
    && echo 'export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin' | sudo tee -a /etc/profile \
    && echo 'export ZOOKEEPER_HOME=/usr/local/software/zookeeper-3.7.1' | sudo tee -a /etc/profile \
    && echo 'export PATH=$PATH:$ZOOKEEPER_HOME/bin' | sudo tee -a /etc/profile \
    && echo 'export HBASE_HOME=/usr/local/software/hbase-2.4.17' | sudo tee -a /etc/profile \
    && echo 'export PATH=$PATH:$HBASE_HOME/bin' | sudo tee -a /etc/profile \
    && echo 'export HIVE_HOME=/usr/local/software/hive-3.1.3' | sudo tee -a /etc/profile \
    && echo 'export PATH=$PATH:$HIVE_HOME/bin' | sudo tee -a /etc/profile \
    && echo 'source /etc/profile' | sudo tee -a /root/.bashrc \
    && localedef -c -f UTF-8 -i zh_CN zh_CN.UTF-8 \
    && echo 'LANG="zh_CN.UTF-8"' > /etc/locale.conf \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && chmod 777 /root/bin/* \
    && /usr/local/software/hadoop-3.3.5/bin/hdfs namenode -format \
    && /usr/local/software/hive-3.1.3/bin/schematool -initSchema -dbType derby \
    && chmod +x /etc/s6-overlay/s6-rc.d/hadoop/* \
    && chmod 700 /root/.ssh \
    && chmod 600 /root/.ssh/* \
    && chmod 0600 /etc/ssh/ \
    && chmod 0600 /etc/ssh/* \
    && echo 'root:root' | chpasswd \
    && sed  's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
    && sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

ENV S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0
ENTRYPOINT ["/init"]
