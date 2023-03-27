FROM centos:centos7
RUN yum update -y \
    && yum install -y rsync wget tar which net-tools openssh-clients openssh-server passwd openssl kde-l10n-Chinese sudo \
    && yum clean all
# arm
ADD jdk-11.0.18_linux-aarch64_bin.tar.gz /usr/local/software/
ADD hadoop-3.3.1-aarch64.tar.gz /usr/local/software/
RUN mv /usr/local/software/hadoop-3.3.1 /usr/local/software/hadoop-3.3.1-aarch64 \
    && mv /usr/local/software/jdk-11.0.18 /usr/local/software/jdk-11.0.18-aarch64
COPY hadoop_arm/* /usr/local/software/hadoop-3.3.1-aarch64/etc/hadoop/
COPY sbin/* /usr/local/software/hadoop-3.3.1-aarch64/sbin/
COPY ENTRYPOINT_arm.sh /ENTRYPOINT_arm.sh
# x86
ADD jdk-11.0.18_linux-x64_bin.tar.gz /usr/local/software/
ADD hadoop-3.3.4.tar.gz /usr/local/software/
RUN mv /usr/local/software/hadoop-3.3.4 /usr/local/software/hadoop-3.3.4-x86 \
    && mv /usr/local/software/jdk-11.0.18 /usr/local/software/jdk-11.0.18-x86
COPY hadoop_x86/* /usr/local/software/hadoop-3.3.4-x86/etc/hadoop/
COPY sbin/* /usr/local/software/hadoop-3.3.4-x86/sbin/
COPY ENTRYPOINT_x86.sh /ENTRYPOINT_x86.sh

WORKDIR /root
COPY ssh_key/* /etc/ssh/
COPY ssh/* /root/.ssh/
COPY bin/* /root/bin/

RUN if [ "$(uname -m)" = "aarch64" ]; then \
    rm -rf /usr/local/software/hadoop-3.3.4-x86 && \
    rm -rf /usr/local/software/jdk-11.0.18-x86 && \
    rm /ENTRYPOINT_x86.sh && \
    mv /usr/local/software/hadoop-3.3.1-aarch64 /usr/local/software/hadoop-3.3.1 && \
    mv /usr/local/software/jdk-11.0.18-aarch64 /usr/local/software/jdk-11.0.18 && \
    mv /ENTRYPOINT_arm.sh /ENTRYPOINT.sh && \
    echo 'export PATH=$PATH:/root/bin' | sudo tee -a /etc/profile && \
    echo 'export JAVA_HOME=/usr/local/software/jdk-11.0.18' | sudo tee -a /etc/profile && \
    echo 'export PATH=$PATH:$JAVA_HOME/bin' | sudo tee -a /etc/profile && \
    echo 'export HADOOP_HOME=/usr/local/software/hadoop-3.3.1' | sudo tee -a /etc/profile && \
    echo 'export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin' | sudo tee -a /etc/profile && \
    echo 'source /etc/profile' | sudo tee -a /root/.bashrc && \
    mkdir -p /root/.ssh && \
    localedef -c -f UTF-8 -i zh_CN zh_CN.UTF-8 && \
    echo 'LANG="zh_CN.UTF-8"' > /etc/locale.conf && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    chmod 777 /root/bin/* && \
    /usr/local/software/hadoop-3.3.1/bin/hdfs namenode -format && \
    chmod +x /ENTRYPOINT.sh && \
    chmod 700 /root/.ssh && \
    chmod 600 /root/.ssh/* && \
    chmod 0600 /etc/ssh/ && \
    chmod 0600 /etc/ssh/*; \
    fi

RUN if [ "$(uname -m)" = "x86_64" ]; then \
    rm -rf /usr/local/software/hadoop-3.3.1-aarch64 && \
    rm -rf /usr/local/software/jdk-11.0.18-aarch64 && \
    rm /ENTRYPOINT_arm.sh && \
    mv /usr/local/software/hadoop-3.3.4-x86 /usr/local/software/hadoop-3.3.4 && \
    mv /usr/local/software/jdk-11.0.18-x86 /usr/local/software/jdk-11.0.18 && \
    mv /ENTRYPOINT_x86.sh /ENTRYPOINT.sh && \
    echo 'export PATH=$PATH:/root/bin' | sudo tee -a /etc/profile && \
    echo 'export JAVA_HOME=/usr/local/software/jdk-11.0.18' | sudo tee -a /etc/profile && \
    echo 'export PATH=$PATH:$JAVA_HOME/bin' | sudo tee -a /etc/profile && \
    echo 'export HADOOP_HOME=/usr/local/software/hadoop-3.3.4' | sudo tee -a /etc/profile && \
    echo 'export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin' | sudo tee -a /etc/profile && \
    echo 'source /etc/profile' | sudo tee -a /root/.bashrc && \
    mkdir -p /root/.ssh && \
    localedef -c -f UTF-8 -i zh_CN zh_CN.UTF-8 && \
    echo 'LANG="zh_CN.UTF-8"' > /etc/locale.conf && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    chmod 777 /root/bin/* && \
    /usr/local/software/hadoop-3.3.4/bin/hdfs namenode -format && \
    chmod +x /ENTRYPOINT.sh && \
    chmod 700 /root/.ssh && \
    chmod 600 /root/.ssh/* && \
    chmod 0600 /etc/ssh/ && \
    chmod 0600 /etc/ssh/*; \
    fi

ENTRYPOINT ["/bin/bash","-c","/ENTRYPOINT.sh"]
