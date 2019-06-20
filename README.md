# Shadowsocks-kcptun
An alpine-based docker image with shadowsocks, kcptun and shadowsocksr for crossing the GFW.

## Step for usage
- 1、Prepare a cloud server with CentOS7 for building proxy services.(vultr, do or bwh...)
- 2、Install Docker<br>
  `yum update`<br>
  `yum install -y yum-utils device-mapper-persistent-data lvm2`<br>
  `yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo`<br>
  `yum -y install docker-ce`<br>
  `systemctl start docker`<br>
  `systemctl enable docker`<br>
- 3、Pull this image<br>
   `docker pull zhoubowen123/shadowsocks-kcptun:tagname`
- 4、Create container<br>
  `docker run --privileged --restart=always -tid  -p 10000:10000 -p 10001:10001 -p 4000:4000/udp -p 4000:4000/tcp zhoubowen123/shadowsocks-kcptun /sbin/init`

## Configuration information
- [kcptun](https://github.com/zhoubowen-sky/shadowsocks-kcptun/blob/master/script/kcptun.json)
- [shadowsocks](https://github.com/zhoubowen-sky/shadowsocks-kcptun/blob/master/script/shadowsocks.json)
- [shadowsocksr](https://github.com/zhoubowen-sky/shadowsocks-kcptun/blob/master/script/shadowsocksr.json)

## Other 
#### Shadowsocks information
- Ss ip: `your clould server ip`
- Ss port: `10000`
- Ss passwd: `qazwsxedc`
- Ss encrypt: `aes-256-gcm`

#### ShadowsocksR information
- Ssr ip: `your clould server ip`
- Ssr port: `10001`
- Ssr passwd: `qazwsxedc`
- Ssr encrypt: `aes-256-cfb`
- Ssr protocol: `auth_aes128_md5`
- Ssr obfs: `tls1.2_ticket_auth`