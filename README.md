# Shadowsocks-kcptun
An alpine-based docker image with shadowsocks + kcptun, brook and shadowsocksr for crossing the GFW.

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
  `docker run --privileged --restart=always -tid  -p 10000:10000 -p 10001:10001 -p 10002:10002 -p 10002:10002/udp -p 4000:4000/udp -p 4000:4000/tcp zhoubowen123/shadowsocks-kcptun /sbin/init`
- 5、Emmmmm...<br>
  Now the server is finished. You can access Google through ss, ssr or brook client, here are parameters for these clients.

## Default parameters for client
### Shadowsocks parameter
- Ss ip: `your server ip`
- Ss port: `10000`
- Ss passwd: `qazwsxedc`
- Ss encrypt: `aes-256-gcm`
### Kcptun (just for ss port 10000)
- kcptun port: `4000`
- kcptun passwd: `qazwsxedc`
- kcptun encrypt: `aes-192`
- kcptun mode: `fast2`
### ShadowsocksR parameter
- Ssr ip: `your server ip`
- Ssr port: `10001`
- Ssr passwd: `qazwsxedc`
- Ssr encrypt: `aes-256-cfb`
- Ssr protocol: `auth_aes128_md5`
- Ssr obfs: `tls1.2_ticket_auth`
### Brook parameter
- Brook ip: `your server ip`
- Brook port: `10002`
- Brook passwd: `qazwsxedc`

## Open bbr
 to be continued ...

## Examples
### Brook
![brook-mac](https://raw.githubusercontent.com/zhoubowen-sky/shadowsocks-kcptun/master/doc/brook-mac.png)

### Ss with kcptun
  kcptun plugin option (for mac):<br>
  `key=qazwsxedc;crypt=aes-192;mode=fast2`<br>
  kcptun plugin option (for windows):<br>
  `-l %SS_LOCAL_HOST%:%SS_LOCAL_PORT% -r %SS_REMOTE_HOST%:%SS_REMOTE_PORT% --key qazwsxedc --crypt aes-192 --mode fast2`
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

## References
- 1、https://github.com/xtaci/kcptun
- 2、https://github.com/shadowsocksrr/shadowsocksr
- 3、https://github.com/shadowsocks/go-shadowsocks2
- 4、https://github.com/txthinking/brook
