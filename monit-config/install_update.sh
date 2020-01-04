#!/bin/sh

# 用途:安装或更新服务信息
# 日期:2020-01-04
# 作者:周博文

LINE=" ====================== "

# 更新系统
yum -y update
echo LINE + "系统更新已经完成" + LINE

# 安装 docker 依赖
yum install -y yum-utils device-mapper-persistent-data lvm2
rm -rf /etc/yum.repos.d/docker-ce.repo
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
echo LINE + "docker依赖包安装完成" + LINE

# 安装 docker 并将其设置为开机启动
yum -y install docker-ce
systemctl start docker
systemctl enable docker
echo LINE + "docker服务安装完成" + LINE

# 拉取 docker 镜像
docker pull zhoubowen123/shadowsocks-kcptun

# 删除 docker 多余镜像
docker images | grep zhoubowen123 | grep

# 删除 docker 多余容器


# 创建 docker 容器
docker run --privileged --restart=always -tid -p 10000:10000 -p 10001:10001 -p 10002:10002/tcp -p 10002:10002/udp -p 10003:10003 -p 4000:4000/udp -p 4000:4000/tcp zhoubowen123/shadowsocks-kcptun /sbin/init