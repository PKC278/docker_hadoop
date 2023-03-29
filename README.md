# docker_hadoop
使用centos7基础镜像搭建伪分布式hadoop集群
支持x86和arm64架构

## 如何使用

从dockerfile编译镜像或者从Docker Hub直接拉取我编译好的镜像

### 1. 从dockerfile编译镜像

1. 克隆仓库

   ```shell
   git clone --depth 1 https://github.com/PKC278/docker_hadoop.git
   ```

2. 从https://www.oracle.com/java/technologies/downloads/ 下载jdk11或jdk8，放到项目根目录，并根据下载的文件名修改dockerfile中相应的文件名。

3. 从https://dlcdn.apache.org/hadoop/common/ 下载hadoop，放到项目根目录，并根据下载的文件名修改dockerfile中相应的文件名。 

4. 在项目根目录下运行下面的命令编译镜像

   ```shell
   docker build -t hadoop:v1 .
   ```

5. 在项目根目录下运行下面的命令启动hadoop集群

   ```shell
   docker-compose up -d
   ```

### 2. 从Docker Hub拉取镜像

1. 拉取镜像

   ```shell
   docker pull pkc123/hadoop
   ```

2. 下载docker compose文件https://github.com/PKC278/docker_hadoop/blob/main/docker-compose.yml 

5. 在docker compose文件同级目录中运行下面的命令启动hadoop集群

   ```shell
   docker-compose up -d
   ```