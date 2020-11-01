# 简介
一个基于CentOS7制作的网络代理程序镜像，镜像包含Trojan、V2ray、Shadowsocks+Kcptun三种代理程序。

## 使用方法
- 1、准备一个CentOS7系统的服务器。
- 2、安装Docker并设置开机启动，相关命令如下<br>
  `yum -y update`<br>
  `yum install -y yum-utils device-mapper-persistent-data lvm2`<br>
  `yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo`<br>
  `yum -y install docker-ce`<br>
  `systemctl start docker`<br>
  `systemctl enable docker`<br>
- 3、将本镜像拉取到服务器上，相关命令如下<br>
   `docker pull zhoubowen123/shadowsocks-kcptun`
- 4、创建对应的容器<br>
  `docker run --privileged --name=passgfw  --restart=always -tid -v /opt/script:/opt/script  -p 80:80/udp -p 80:80/tcp  -p 443:443/udp -p 443:443/tcp  -p 444:444/udp -p 444:444/tcp  -p 4000:4000/udp -p 4000:4000/tcp  zhoubowen123/shadowsocks-kcptun /usr/sbin/init`

- 5、上传SSL证书<br>
  若需使用镜像中的trojan以及v2ray则需申请对应的域名及证书。
  

## 本镜像默认的配置
### Trojan参数
TROJAN参数名 | 参数取值
-: | :-
服务器地址(ip) | 代理服务器IP
端口(port) | 444
密码(passwd) | qazwsxedc

### Kcptun参数
KCPTUN参数名 | 参数取值
-: | :-
服务器地址(ip) | 代理服务器IP
端口(port) | 4000
密码(passwd) | qazwsxedc
加密方式(encrypt) | aes-192
模式(mode) | fast3
过期时间(autoexpire) | 60

### Shadowsocks参数
SHADOWSOCKS参数名 | 参数取值
-: | :-
服务器地址(ip) | 代理服务器IP
端口(port) | 10000
密码(passwd) | qazwsxedc
加密方式(encrypt) | aes-256-gcm

### V2ray + ws 参数
V2RAY参数名 | 参数取值
-: | :-
服务器地址(ip) | 代理服务器IP
Nginx端口(port) | 443
V2ray端口(port) | 10001
ID(uuid) | 见配置文件
AlterId | 见配置文件
StreamSettings | websocket
WebsocketPath | /ray

## 开启BBR
 CentOS开启BRR可参阅 [OPEN BBR](https://www.vultr.com/docs/how-to-deploy-google-bbr-on-centos-7) ...

## 客户端配置例子

### Shadowsocks+kcptun
  kcptun插件参数 (mac):<br>
  `key=qazwsxedc;crypt=aes-192;mode=fast3;autoexpire=60`<br>
  kcptun插件参数 (windows):<br>
  `-l %SS_LOCAL_HOST%:%SS_LOCAL_PORT% -r %SS_REMOTE_HOST%:%SS_REMOTE_PORT% --key qazwsxedc --crypt aes-192 --mode fast3 --autoexpire 60`
![ss-kcp-mac](https://raw.githubusercontent.com/zhoubowen-sky/shadowsocks-kcptun/master/doc/ss-kcp-mac.png)
![ss-kcp-win](https://raw.githubusercontent.com/zhoubowen-sky/shadowsocks-kcptun/master/doc/ss-kcp-win.png)

## 容器内服务端的配置文件
- [kcptun配置文件](https://github.com/zhoubowen-sky/shadowsocks-kcptun/blob/master/script/kcptun_server.json)
- [shadowsocks配置文件](https://github.com/zhoubowen-sky/shadowsocks-kcptun/blob/master/script/shadowsocks2Console)
- [trojan配置文件](https://github.com/zhoubowen-sky/shadowsocks-kcptun/blob/master/script/trojan_server.json)
- [v2ray配置文件](https://github.com/zhoubowen-sky/shadowsocks-kcptun/blob/master/script/v2ray_server.json)

## 服务端相关代理程序端口使用情况

进程名称 | 所用端口
:-: | :-:
v2ray+ws+tls+nginx | 443+80
trojan | 444
kcptun | 4000
shadowsocks-go2 | 10000

## References
- 1、https://github.com/xtaci/kcptun
- 2、https://github.com/shadowsocks/go-shadowsocks2
- 3、https://github.com/trojan-gfw/trojan
- 4、https://github.com/v2ray/v2ray-core
