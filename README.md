# docker_hadoop
使用centos7基础镜像搭建伪分布式hadoop集群
支持x86和arm64架构

镜像包含以下服务：

- hadoop-3.3.6
- hbase-2.5.5
- zookeeper-3.8.3
- apache-hive-3.1.3
- sqoop-1.4.7
- mysql-community-client_8
- jdk8
- spark-3.5.0
- scala-2.13.12

已配置mysql为默认Metastore Database

**注意：本项目只用于研究学习，未对生产环境进行过测试**

## 如何使用

从dockerfile编译镜像或者直接拉取编译好的镜像

docker-compose映射容器22端口到主机9000端口，用户为root密码为root

### 1. 从dockerfile编译镜像

1. 克隆仓库

   ```shell
   git clone --depth 1 https://github.com/PKC278/docker_hadoop.git
   ```

4. 在项目根目录下运行下面的命令编译镜像

   ```shell
   docker build -t hadoop:v1 .
   ```

5. 修改docker-compose.yml中所调用镜像的标签为hadoop:v1

6. 在项目根目录下运行下面的命令启动hadoop集群

   ```shell
   docker-compose -f docker-compose.yml -p docker_hadoop up -d
   ```

### 2. 从Docker Hub拉取镜像

1. 拉取镜像

   ```shell
   docker pull pkc278/hadoop
   ```

   或

   ```shell
   docker pull ghcr.io/pkc278/hadoop
   ```


2. 下载[docker-compose.yml](https://raw.githubusercontent.com/PKC278/docker_hadoop/main/docker-compose.yml)文件

5. 在docker-compose.yml文件同级目录中运行下面的命令启动hadoop集群

   ```shell
   docker-compose -f docker-compose.yml -p docker_hadoop up -d
   ```
