
######################
## PRODUCTION STAGE ##
######################
FROM ubuntu:latest
LABEL maintainer "zhoubowen <zhoubowen.sky@gmail.com>"

ENV SS_LIBEV_URL=https://github.com/shadowsocks/shadowsocks-libev.git
ENV KCPTUN_URL=https://github.com/xtaci/kcptun/releases/download/v20200409/kcptun-linux-amd64-20200409.tar.gz
ENV TROJAN_URL=https://github.com/trojan-gfw/trojan.git

WORKDIR /opt
ADD . .

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN echo 'Asia/Shanghai' >/etc/timezone

RUN apt update
RUN apt -y install wget curl git gcc build-essential

# 安装 kcptun
RUN cd /tmp && wget ${KCPTUN_URL} && tar -xf *.gz && mv server_linux_amd64 /usr/local/sbin/kcptun_server && rm -rf /tmp/*

# 编译 trojan
RUN apt -y install cmake libboost-all-dev openssl libssl-dev libmysqlclient-dev
RUN git clone ${TROJAN_URL} \
    && (cd trojan && cmake . && make && mv trojan /usr/local/sbin) \
    && rm -rf trojan

# 编译 shadowsocks-libev
RUN apt -y install libpcre3 libpcre3-dev libmbedtls-dev libtool  asciidoc xmlto libev-dev libc-ares-dev automake  libsodium-dev
RUN git clone ${SS_LIBEV_URL} \
    && (cd shadowsocks-libev \
    && git submodule update --init --recursive \
    && ./autogen.sh \
    && ./configure --prefix=/usr --disable-documentation \
    && make && make install) \
    && rm -rf shadowsocks-libev

# 安装 v2ray
RUN curl -L -o /tmp/go.sh https://install.direct/go.sh
RUN chmod +x /tmp/go.sh
RUN /tmp/go.sh && rm -rf /tmp/go.sh

# 安装 nginx
RUN apt install -y nginx

# 安装 monit
RUN apt install -y monit
RUN rm -rf /etc/monit.d \
    && cp -rf monit-config/monit.d /etc/ \
    && rm -rf /etc/monitrc \
    && cp -rf monit-config/monitrc /etc/ \
    && chown root:root /etc/monitrc \
    && chmod 0700 /etc/monitrc

# copy shadowsocks kcptun and trojan configuration files
RUN cd /opt/script && chmod a+x *Console

# 启动 monit