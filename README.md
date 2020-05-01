# Shadowsocks-kcptun
An alpine-based docker image with shadowsocks + kcptun, brook, trojan, v2ray and shadowsocksr for crossing the GFW.

## Step for usage
- 1、Prepare a cloud server with CentOS7 for building proxy services.(vultr, do or bwh...)
- 2、Install Docker<br>
  `yum -y update`<br>
  `yum install -y yum-utils device-mapper-persistent-data lvm2`<br>
  `yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo`<br>
  `yum -y install docker-ce`<br>
  `systemctl start docker`<br>
  `systemctl enable docker`<br>
- 3、Pull this image<br>
   `docker pull zhoubowen123/shadowsocks-kcptun`
- 4、Create a container<br>
  Open v2ray and shadowsocks + kcptun:<br>
  `docker run --privileged --restart=always -tid -v /opt/script:/opt/script -p 443:443/udp -p 443:443/tcp -p 4000:4000/udp -p 4000:4000/tcp zhoubowen123/shadowsocks-kcptun /sbin/init`<br>
  Open v2ray, trojan, shadowsocks and shadowsocks + kcptun:<br>
  `docker run --privileged --restart=always -tid -v /opt/script:/opt/script -p 443:443/udp -p 443:443/tcp -p 444:444/udp -p 444:444/tcp -p 4000:4000/udp -p 4000:4000/tcp -p 10000:10000/udp -p 10000:10000/tcp zhoubowen123/shadowsocks-kcptun /sbin/init`<br>
  Open v2ray, trojan, shadowsocks, shadowsocks + kcptun, brook and ssr:<br>
  `docker run --privileged --restart=always -tid -v /opt/script:/opt/script -p 443:443/udp -p 443:443/tcp -p 444:444/udp -p 444:444/tcp -p 4000:4000/udp -p 4000:4000/tcp -p 10000:10000/udp -p 10000:10000/tcp -p 10001:10001/udp -p 10001:10001/tcp -p 10002:10002/udp -p 10002:10002/tcp zhoubowen123/shadowsocks-kcptun /sbin/init`<br>
- 5、Upload SSL certificate to server<br>
  Upload your SSL cert files to server.
  
  
- 5、Emmmmm...<br>
  Now the server is finished. You can access Google through ss, ssr, trojan or brook clients, here are parameters for these clients.

## Default parameters for client
### Trojan
TROJAN参数名 | 参数取值
-: | :-
服务器地址(ip) | 代理服务器IP
端口(port) | 443
密码(passwd) | qazwsxedc

### Kcptun (just for ss port 10000)
KCPTUN参数名 | 参数取值
-: | :-
服务器地址(ip) | 代理服务器IP
端口(port) | 4000
密码(passwd) | qazwsxedc
加密方式(encrypt) | aes-192
模式(mode) | fast3
过期时间(autoexpire) | 60

### Shadowsocks parameter
SHADOWSOCKS参数名 | 参数取值
-: | :-
服务器地址(ip) | 代理服务器IP
端口(port) | 10000
密码(passwd) | qazwsxedc
加密方式(encrypt) | aes-256-gcm

### ShadowsocksR parameter
SHADOWSOCKSR参数名 | 参数取值
-: | :-
服务器地址(ip) | 代理服务器IP
端口(port) | 10001
密码(passwd) | qazwsxedc
加密方式(encrypt) | aes-256-cfb
加密协议(protocol) | auth_aes128_md5
混淆方式(obfs) | tls1.2_ticket_auth

### Brook parameter
BROOK参数名 | 参数取值
-: | :-
服务器地址(ip) | 代理服务器IP
端口(port) | 10002
密码(passwd) | qazwsxedc

## Open bbr
 To be continued ... <br>
 For [CentOS7](https://www.vultr.com/docs/how-to-deploy-google-bbr-on-centos-7) ...

## Examples
### Brook
![brook-mac](https://raw.githubusercontent.com/zhoubowen-sky/shadowsocks-kcptun/master/doc/brook-mac.png)

### Ss with kcptun
  kcptun plugin option (for mac):<br>
  `key=qazwsxedc;crypt=aes-192;mode=fast3;autoexpire=60`<br>
  kcptun plugin option (for windows):<br>
  `-l %SS_LOCAL_HOST%:%SS_LOCAL_PORT% -r %SS_REMOTE_HOST%:%SS_REMOTE_PORT% --key qazwsxedc --crypt aes-192 --mode fast3 --autoexpire 60`
![ss-kcp-mac](https://raw.githubusercontent.com/zhoubowen-sky/shadowsocks-kcptun/master/doc/ss-kcp-mac.png)
![ss-kcp-win](https://raw.githubusercontent.com/zhoubowen-sky/shadowsocks-kcptun/master/doc/ss-kcp-win.png)

### Ss without kcptun
![ss-mac](https://raw.githubusercontent.com/zhoubowen-sky/shadowsocks-kcptun/master/doc/ss-mac.png)

### Ssr for ios
![ssr-ios](https://raw.githubusercontent.com/zhoubowen-sky/shadowsocks-kcptun/master/doc/ssr-ios.png)

## Server configuration information
- [kcptun](https://github.com/zhoubowen-sky/shadowsocks-kcptun/blob/master/script/kcptun.json)
- [shadowsocks](https://github.com/zhoubowen-sky/shadowsocks-kcptun/blob/master/script/shadowsocks.json)
- [shadowsocksr](https://github.com/zhoubowen-sky/shadowsocks-kcptun/blob/master/script/shadowsocksr.json)
- [trojan](https://github.com/zhoubowen-sky/shadowsocks-kcptun/blob/master/script/trojan_server.json)
- [v2ray](https://github.com/zhoubowen-sky/shadowsocks-kcptun/blob/master/script/v2ray_server.json)

## 相关端口使用情况

应用名称 | 所用端口
:-: | :-:
trojan | 444
v2ray+ws+tls+nginx | 443+80
kcptun | 4000
shadowsocks-libev | 10000
shadowsocksr | 10001
brook | 10002

## References
- 1、https://github.com/xtaci/kcptun
- 2、https://github.com/shadowsocksrr/shadowsocksr
- 3、https://github.com/txthinking/brook
- 4、https://github.com/shadowsocks/shadowsocks-libev
- 5、https://github.com/trojan-gfw/trojan
- 6、https://github.com/v2ray/v2ray-core
