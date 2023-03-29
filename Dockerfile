FROM centos:centos7
RUN yum update -y \
    && yum install -y rsync wget tar which net-tools openssh-clients openssh-server passwd openssl kde-l10n-Chinese sudo \
    && yum clean all \
    && mkdir -p /root/software \
    && mkdir -p /usr/local/software

RUN if [ "$(uname -m)" = "aarch64" ]; then \
    wget -O /root/software/jdk.tar.gz https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.18%2B10/OpenJDK11U-jdk_aarch64_linux_hotspot_11.0.18_10.tar.gz && \
    wget -O /root/software/hadoop.tar.gz https://dlcdn.apache.org/hadoop/common/hadoop-3.3.5/hadoop-3.3.5-aarch64.tar.gz ; \
    elif [ "$(uname -m)" = "x86_64" ]; then \
    wget -O /root/software/jdk.tar.gz https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.18%2B10/OpenJDK11U-jdk_x64_linux_hotspot_11.0.18_10.tar.gz && \
    wget -O /root/software/hadoop.tar.gz https://dlcdn.apache.org/hadoop/common/hadoop-3.3.5/hadoop-3.3.5.tar.gz ; \
    fi

WORKDIR /root
COPY bin /root/software/

RUN mkdir -p /root/.ssh \
    && mv /root/software/bin /root/ \
    && mv /root/software/ssh_key/* /etc/ssh/ \
    && mv /root/software/ssh/* /root/.ssh/ \
    && tar -zxvf /root/software/jdk.tar.gz -C /usr/local/software/ \
    && tar -zxvf /root/software/hadoop.tar.gz -C /usr/local/software/ \
    && mv /root/software/ENTRYPOINT.sh /ENTRYPOINT.sh \
    && mv /root/software/hadoop/* /usr/local/software/hadoop-3.3.5/etc/hadoop/ \
    && mv /root/software/sbin/* /usr/local/software/hadoop-3.3.5/sbin/ \
    && rm -rf /root/software/ \
    && echo 'export PATH=$PATH:/root/bin' | sudo tee -a /etc/profile \
    && echo 'export JAVA_HOME=/usr/local/software/jdk-11.0.18+10' | sudo tee -a /etc/profile \
    && echo 'export PATH=$PATH:$JAVA_HOME/bin' | sudo tee -a /etc/profile \
    && echo 'export HADOOP_HOME=/usr/local/software/hadoop-3.3.5' | sudo tee -a /etc/profile \
    && echo 'export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin' | sudo tee -a /etc/profile \
    && echo 'source /etc/profile' | sudo tee -a /root/.bashrc \
    && localedef -c -f UTF-8 -i zh_CN zh_CN.UTF-8 \
    && echo 'LANG="zh_CN.UTF-8"' > /etc/locale.conf \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && chmod 777 /root/bin/* \
    && /usr/local/software/hadoop-3.3.5/bin/hdfs namenode -format \
    && chmod +x /ENTRYPOINT.sh \
    && chmod 700 /root/.ssh \
    && chmod 600 /root/.ssh/* \
    && chmod 0600 /etc/ssh/ \
    && chmod 0600 /etc/ssh/*

ENTRYPOINT ["/bin/bash","-c","/ENTRYPOINT.sh"]
