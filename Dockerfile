FROM centos:centos7 as builder
RUN yum makecache \
    && yum install -y wget ca-certificates \
    && mkdir -p /usr/local/software \
    && wget -O /tmp/hbase.tar.gz https://dlcdn.apache.org/hbase/stable/hbase-2.5.5-bin.tar.gz \
    && wget -O /tmp/zookeeper.tar.gz https://dlcdn.apache.org/zookeeper/stable/apache-zookeeper-3.8.3-bin.tar.gz \
    && wget -O /tmp/hive.tar.gz https://dlcdn.apache.org/hive/hive-3.1.3/apache-hive-3.1.3-bin.tar.gz \
    && wget -O /tmp/sqoop.tar.gz https://archive.apache.org/dist/sqoop/1.4.7/sqoop-1.4.7.tar.gz \
    && wget -O /tmp/sqoop.bin.tar.gz https://archive.apache.org/dist/sqoop/1.4.7/sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz \
    && wget -O /tmp/spark.bin.tar.gz https://dlcdn.apache.org/spark/spark-3.5.0/spark-3.5.0-bin-hadoop3-scala2.13.tgz \
    && wget -O /tmp/mysql-connector-j.tar.gz https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-j-8.1.0.tar.gz \
    && wget -O /tmp/s6-overlay-noarch.tar.xz https://github.com/just-containers/s6-overlay/releases/download/v3.1.5.0/s6-overlay-noarch.tar.xz \
    && wget -O /tmp/scala.tar.gz https://downloads.lightbend.com/scala/2.13.12/scala-2.13.12.tgz \
    && if [ "$(uname -m)" = "aarch64" ]; then \
    wget -O /tmp/s6-overlay.tar.xz https://github.com/just-containers/s6-overlay/releases/download/v3.1.5.0/s6-overlay-aarch64.tar.xz  && \
    wget -O /tmp/jdk.tar.gz https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u372-b07/OpenJDK8U-jdk_aarch64_linux_hotspot_8u372b07.tar.gz && \
    wget -O /tmp/hadoop.tar.gz https://dlcdn.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6-aarch64.tar.gz ; \
    elif [ "$(uname -m)" = "x86_64" ]; then \
    wget -O /tmp/s6-overlay.tar.xz https://github.com/just-containers/s6-overlay/releases/download/v3.1.5.0/s6-overlay-x86_64.tar.xz  && \
    wget -O /tmp/jdk.tar.gz https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u372-b07/OpenJDK8U-jdk_x64_linux_hotspot_8u372b07.tar.gz && \
    wget -O /tmp/hadoop.tar.gz https://dlcdn.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz ; \
    fi

COPY bin /tmp/
RUN tar -zxvf /tmp/jdk.tar.gz -C /usr/local/software/ > /dev/null \
    && tar -zxvf /tmp/hadoop.tar.gz -C /usr/local/software/ > /dev/null \
    && tar -zxvf /tmp/hbase.tar.gz -C /usr/local/software/ > /dev/null \
    && tar -zxvf /tmp/zookeeper.tar.gz -C /usr/local/software/ > /dev/null \
    && tar -zxvf /tmp/hive.tar.gz -C /usr/local/software/ > /dev/null \
    && tar -zxvf /tmp/sqoop.tar.gz -C /usr/local/software/ > /dev/null \
    && tar -zxvf /tmp/sqoop.bin.tar.gz -C /tmp/ > /dev/null \
    && tar -zxvf /tmp/spark.bin.tar.gz -C /usr/local/software/ > /dev/null \
    && tar -zxvf /tmp/mysql-connector-j.tar.gz -C /tmp/ > /dev/null \
    && tar -zxvf /tmp/scala.tar.gz -C /usr/local/software/ > /dev/null \
    && mv /usr/local/software/apache-hive-3.1.3-bin/ /usr/local/software/hive-3.1.3 \
    && mv /usr/local/software/apache-zookeeper-3.8.3-bin/ /usr/local/software/zookeeper-3.8.3 \
    && mv /usr/local/software/spark-3.5.0-bin-hadoop3-scala2.13 /usr/local/software/spark-3.5.0 \
    && mv /tmp/hadoop/* /usr/local/software/hadoop-3.3.6/etc/hadoop/ \
    && mv /tmp/sbin/* /usr/local/software/hadoop-3.3.6/sbin/ \
    && mv /tmp/hbase/* /usr/local/software/hbase-2.5.5/conf/ \
    && mv /tmp/Zookeeper/* /usr/local/software/zookeeper-3.8.3/conf \
    && mv /tmp/hive/* /usr/local/software/hive-3.1.3/conf \
    && mv /tmp/sqoop/* /usr/local/software/sqoop-1.4.7/conf \
    && mv /tmp/spark/* /usr/local/software/spark-3.5.0/conf \
    && mv /tmp/sqoop-1.4.7.bin__hadoop-2.6.0/sqoop-1.4.7.jar /usr/local/software/hadoop-3.3.6/share/hadoop/yarn/ \
    && cp /tmp/mysql-connector-j-8.1.0/mysql-connector-j-8.1.0.jar /usr/local/software/sqoop-1.4.7/lib/ \
    && cp /tmp/mysql-connector-j-8.1.0/mysql-connector-j-8.1.0.jar /usr/local/software/hive-3.1.3/lib/ \
    && mkdir -p /usr/local/software/hbase-2.5.5/data/tmp \
    && mkdir -p /usr/local/software/zookeeper-3.8.3/datadir \
    && mkdir -p /usr/local/software/zookeeper-3.8.3/log \
    && touch /usr/local/software/zookeeper-3.8.3/datadir/myid \
    && cp /usr/local/software/hadoop-3.3.6/etc/hadoop/hdfs-site.xml /usr/local/software/hbase-2.5.5/conf/ \
    && mkdir -p /usr/local/software/data \
    && mv /tmp/bin /usr/local/software/data/ \
    && mv /tmp/ssh_key /usr/local/software/data/ \
    && mv /tmp/ssh /usr/local/software/data/ \
    && mv /tmp/s6-overlay-noarch.tar.xz /usr/local/software/data/ \
    && mv /tmp/s6-overlay.tar.xz /usr/local/software/data/ \
    && mv /tmp/s6-rc.d /usr/local/software/data/

FROM centos:centos7 as runtime
ADD https://dev.mysql.com/get/mysql80-community-release-el7-10.noarch.rpm /tmp/mysql.rpm
RUN rpm -ivh /tmp/mysql.rpm \
    && yum update -y \
    && yum install -y rsync wget tar which net-tools openssh-clients openssh-server passwd openssl kde-l10n-Chinese sudo mysql-community-client nc \
    && yum clean all \
    && rm -rf /tmp/*

COPY --from=builder /usr/local/software /usr/local/software
RUN mkdir -p /root/.ssh \
    && mv /usr/local/software/data/bin /root/ \
    && mv /usr/local/software/data/ssh_key/* /etc/ssh/ \
    && mv /usr/local/software/data/ssh/* /root/.ssh/ \
    && tar -C / -Jxpf /usr/local/software/data/s6-overlay-noarch.tar.xz > /dev/null \
    && tar -C / -Jxpf /usr/local/software/data/s6-overlay.tar.xz > /dev/null \
    && mv /usr/local/software/data/s6-rc.d/hadoop /etc/s6-overlay/s6-rc.d/ \
    && touch /etc/s6-overlay/s6-rc.d/user/contents.d/hadoop \
    && localedef -c -f UTF-8 -i zh_CN zh_CN.UTF-8 \
    && echo 'LANG="zh_CN.UTF-8"' > /etc/locale.conf \
    && echo 'export PATH=$PATH:/root/bin' | sudo tee -a /etc/profile \
    && echo 'export SQOOP_HOME=/usr/local/software/sqoop-1.99.7' | sudo tee -a /etc/profile \
    && echo 'export PATH=$PATH:$SQOOP_HOME/bin' | sudo tee -a /etc/profile \
    && echo 'export JAVA_HOME=/usr/local/software/jdk8u372-b07' | sudo tee -a /etc/profile \
    && echo 'export PATH=$PATH:$JAVA_HOME/bin' | sudo tee -a /etc/profile \
    && echo 'export HADOOP_HOME=/usr/local/software/hadoop-3.3.6' | sudo tee -a /etc/profile \
    && echo 'export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin' | sudo tee -a /etc/profile \
    && echo 'export ZOOKEEPER_HOME=/usr/local/software/zookeeper-3.8.3' | sudo tee -a /etc/profile \
    && echo 'export PATH=$PATH:$ZOOKEEPER_HOME/bin' | sudo tee -a /etc/profile \
    && echo 'export HBASE_HOME=/usr/local/software/hbase-2.5.5' | sudo tee -a /etc/profile \
    && echo 'export PATH=$PATH:$HBASE_HOME/bin' | sudo tee -a /etc/profile \
    && echo 'export HIVE_HOME=/usr/local/software/hive-3.1.3' | sudo tee -a /etc/profile \
    && echo 'export PATH=$PATH:$HIVE_HOME/bin' | sudo tee -a /etc/profile \
    && echo 'export SPARK_HOME=/usr/local/software/spark-3.5.0' | sudo tee -a /etc/profile \
    && echo 'export PATH=$PATH:$SPARK_HOME/bin' | sudo tee -a /etc/profile \
    && echo 'export SCALA_HOME=/usr/local/software/scala-2.13.12' | sudo tee -a /etc/profile \
    && echo 'export PATH=$PATH:$SCALA_HOME/bin' | sudo tee -a /etc/profile \
    && echo 'export LC_ALL=zh_CN.UTF-8' | sudo tee -a /etc/profile \
    && echo 'export LANG=zh_CN.UTF-8' | sudo tee -a /etc/profile \
    && echo 'export LANGUAGE=zh_CN.UTF-8' | sudo tee -a /etc/profile \
    && echo 'source /etc/profile' | sudo tee -a /root/.bashrc \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && chmod +x /root/bin/* \
    && find /usr/local/software -type f -name "*.sh" -exec chmod +x {} \; \
    && chmod +x /etc/s6-overlay/s6-rc.d/hadoop/* \
    && chmod 700 /root/.ssh \
    && chmod 600 /root/.ssh/* \
    && chmod 0600 /etc/ssh/ \
    && chmod 0600 /etc/ssh/* \
    && echo 'root:root' | chpasswd \
    && sed  's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
    && sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && rm -rf /usr/local/software/data \
    && rm -rf /tmp/* \
    && find / -name "*.core" -exec rm -f {} \;

WORKDIR /root
ENV S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0
ENTRYPOINT ["/init"]
