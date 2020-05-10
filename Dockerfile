
# ##################
# ## BUILD STAGE ##
# ##################
# FROM ubuntu:latest as builder
# LABEL maintainer "zhoubowen <zhoubowen.sky@gmail.com>"

# ENV SS_LIBEV_URL=https://github.com/shadowsocks/shadowsocks-libev.git
# ENV TROJAN_URL=https://github.com/trojan-gfw/trojan.git

# WORKDIR /opt
# ADD . .

# # 设定时区
# RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
#     && echo 'Asia/Shanghai' >/etc/timezone

# RUN apt update 
# # 安装基础依赖库
# RUN apt -y install wget curl git gcc build-essential
# # 安装 trojan 依赖库
# RUN apt -y install cmake libboost-all-dev openssl libssl-dev libmysqlclient-dev
# # 安装 shadowsocks-libev 依赖库
# RUN apt -y install libpcre3-dev libmbedtls-dev libsodium-dev libc-ares-dev libev-dev 

# # 编译 trojan
# RUN git clone ${TROJAN_URL} \
#     && (cd trojan && cmake . && make && mv trojan /usr/local/sbin)

# # 编译 shadowsocks-libev
# RUN git clone ${SS_LIBEV_URL} \
#     && cd shadowsocks-libev \
#     && git submodule update --init --recursive \
#     && ./autogen.sh \
#     && ./configure --prefix=/usr --disable-documentation \
#     && make && make install


######################
## PRODUCTION STAGE ##
######################
FROM ubuntu:16.04
LABEL maintainer "zhoubowen <zhoubowen.sky@gmail.com>"

ENV KCPTUN_URL=https://github.com/xtaci/kcptun/releases/download/v20200409/kcptun-linux-amd64-20200409.tar.gz
ENV V2RAY_URL=https://github.com/v2ray/v2ray-core/releases/download/v4.23.1/v2ray-linux-64.zip
ENV TROJAN_BIN_URL=https://github.com/trojan-gfw/trojan/releases/download/v1.15.1/trojan-1.15.1-linux-amd64.tar.xz

WORKDIR /opt
ADD . .

# 设定时区
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' >/etc/timezone

RUN apt update 
RUN apt -y install --no-install-recommends wget curl unzip xz-utils \
    # 安装 nginx
    nginx \
    # 安装 monit
    monit

# 安装 trojan
RUN wget --no-check-certificate ${TROJAN_BIN_URL} \
    && xz -d *.xz \
    && tar xvf *.tar \
    && cp trojan/trojan /usr/local/sbin/

# 安装 ss
#COPY --from=builder /usr/bin/ss-local       /usr/bin/
#COPY --from=builder /usr/bin/ss-manager     /usr/bin/
#COPY --from=builder /usr/bin/ss-nat         /usr/bin/
#COPY --from=builder /usr/bin/ss-redir       /usr/bin/
#COPY --from=builder /usr/bin/ss-server      /usr/bin/
#COPY --from=builder /usr/bin/ss-tunnel      /usr/bin/

# 安装 kcptun
# RUN mkdir -p /go/bin && cd /go/bin && wget --no-check-certificate ${KCPTUN_URL} \
#     && tar -xf *.gz && cp -f server_linux_amd64 /usr/local/sbin/kcptun_server

# 安装 v2ray
RUN wget --no-check-certificate ${V2RAY_URL} \ 
    && unzip v2ray-linux-64.zip -d /usr/bin/v2ray/

# 安装 monit
RUN rm -rf /etc/monit.d \
    && cp -rf monit-config/monit.d /etc/ \
    && rm -rf /etc/monitrc \
    && cp -rf monit-config/monitrc /etc/ \
    && chown root:root /etc/monitrc \
    && chmod 0700 /etc/monitrc

# copy shadowsocks kcptun and trojan configuration files
RUN cd /opt/script && chmod a+x *Console

# 开机启动 monit
RUN cp -rf script/rc.local /etc/ \
    && cp -rf script/nginx/nginx.conf /lib/systemd/system/nginx.service
