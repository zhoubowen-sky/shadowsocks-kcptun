
#################
## BUILD STAGE ##
#################
FROM golang:1.14.2 AS build

LABEL maintainer "zhoubowen <zhoubowen.sky@gmail.com>"

# build go-shadowsocks2 binary file
RUN go get -d -v github.com/shadowsocks/go-shadowsocks2 \
    && go install -ldflags '-w -s' -tags netgo -v github.com/shadowsocks/go-shadowsocks2


######################
## PRODUCTION STAGE ##
######################
FROM centos:7
LABEL maintainer "zhoubowen <zhoubowen.sky@gmail.com>"

ENV KCPTUN_URL=https://github.com/xtaci/kcptun/releases/download/v20200409/kcptun-linux-amd64-20200409.tar.gz
ENV V2RAY_URL=https://github.com/v2ray/v2ray-core/releases/download/v4.25.1/v2ray-linux-64.zip
ENV TROJAN_BIN_URL=https://github.com/trojan-gfw/trojan/releases/download/v1.16.0/trojan-1.16.0-linux-amd64.tar.xz

WORKDIR /opt
ADD . .

# 设定时区
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' >/etc/timezone \
# 安装基础工具
    && yum -y update \
    && yum -y install wget curl unzip xz-utils \
# 安装 nginx
    && rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm \
    && yum -y install nginx \
# 安装 monit
    && yum -y install epel-release \
    && yum -y install monit

# 安装 shadowsocks-go2
COPY --from=build /go/bin/go-shadowsocks2 /usr/local/sbin/go-shadowsocks2

# 安装 trojan
RUN wget --no-check-certificate ${TROJAN_BIN_URL} \
    && xz -d *.xz \
    && tar xvf *.tar \
    && cp trojan/trojan /usr/local/sbin/ \
# 安装 kcptun
    && wget --no-check-certificate ${KCPTUN_URL} \
    && tar -xf *.gz && cp -f server_linux_amd64 /usr/local/sbin/kcptun_server \
# 安装 v2ray
    && wget --no-check-certificate ${V2RAY_URL} \ 
    && unzip v2ray-linux-64.zip -d /usr/bin/v2ray/ \
# 安装 monit
    && rm -rf /etc/monit.d \
    && cp -rf monit-config/monit.d /etc/ \
    && rm -rf /etc/monitrc \
    && cp -rf monit-config/monitrc /etc/ \
    && chown root:root /etc/monitrc \
    && chmod 0700 /etc/monitrc \
# 安装 start-stop-daemon 
    && chmod +x script/start-stop-daemon \
    && cp script/start-stop-daemon /usr/bin/start-stop-daemon \
# 设定 monit 开机启动 
    && /usr/bin/systemctl enable monit \
    # 删除多余文件
    && rm -rf .git doc trojan* v2ray* kcptun-linux* client_linux* server_linux* \
# 给脚本可执行权限
    && cd /opt/script && chmod a+x *Console \
    # 删除缓存及无用的软件
    && yum -y remove wget unzip && yum clean all 
