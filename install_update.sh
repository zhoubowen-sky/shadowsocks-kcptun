#!/bin/sh

# 用途:安装或更新服务信息
# 日期:2020-01-04
# 作者:zhoubowen.sky@gmail.com

LINE=" ====================== "

# 更新系统
#yum -y update
#echo $LINE + "系统更新已经完成" + $LINE
#sleep 1

# 安装 git
yum install -y git

# 安装 docker 依赖
yum install -y yum-utils device-mapper-persistent-data lvm2
rm -rf /etc/yum.repos.d/docker-ce.repo
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
echo $LINE + "docker依赖包安装完成" + $LINE
sleep 1

# 安装 docker 并将其设置为开机启动
yum -y install docker-ce
systemctl start docker
systemctl enable docker
echo $LINE + "docker服务安装完成" + $LINE
sleep 3

# 拉取 docker 镜像
docker pull zhoubowen123/shadowsocks-kcptun
sleep 1

# 删除 docker 多余容器
docker ps -a | grep 443 | awk '{print $1}' | xargs docker rm -f
sleep 1

# 删除 docker 多余镜像
docker images | grep zhoubowen123 | grep none | awk '{print $3}' | xargs docker rmi -f
sleep 1

# 下载 github 的配置文件
rm -rf /shadowsocks-kcptun && cd /
git clone https://github.com/zhoubowen-sky/shadowsocks-kcptun.git
mkdir -p /opt/script/
cp -rf /shadowsocks-kcptun/script/* /opt/script/

# 创建 docker 容器
docker run --privileged --restart=always -tid -v /opt/script:/opt/script -p 443:443/udp -p 443:443/tcp -p 4000:4000/udp -p 4000:4000/tcp -p 10000:10000/udp -p 10000:10000/tcp -p 10800:10800/udp -p 10800:10800/tcp zhoubowen123/shadowsocks-kcptun /sbin/init
