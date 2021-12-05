# 简介
一个基于CentOS7制作的网络代理程序镜像，镜像包含V2ray代理程序。

## 使用方法
- 1、准备一个CentOS7系统的服务器。
- 2、安装Docker并设置开机启动，相关命令如下<br>
  `yum -y update`<br>
  `yum install -y yum-utils device-mapper-persistent-data lvm2`<br>
  `yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo`<br>
  `yum -y install docker-ce`<br>
  `systemctl start docker`<br>
  `systemctl enable docker`<br>
- 3、使用本仓库构建本地镜像
  `docker build github.com/zhoubowen-sky/shadowsocks-kcptun`
- 4、创建对应的容器<br>
  `docker run --privileged --name=passgfw  --restart=always -tid -v /opt/script:/opt/script  -p 80:80/udp -p 80:80/tcp  -p 443:443/udp -p 443:443/tcp zhoubowen123/shadowsocks-kcptun /usr/sbin/init`

- 5、上传SSL证书<br>
  需申请对应的域名及证书。

## 开启BBR
 CentOS开启BRR可参阅 [OPEN BBR](https://www.vultr.com/docs/how-to-deploy-google-bbr-on-centos-7) ...

## References
- 1、https://github.com/v2fly/v2ray-core
