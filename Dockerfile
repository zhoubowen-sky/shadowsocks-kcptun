
##################
## BUILD STAGE ##
##################
FROM ubuntu:latest as builder
LABEL maintainer "zhoubowen <zhoubowen.sky@gmail.com>"

ENV SS_LIBEV_URL=https://github.com/shadowsocks/shadowsocks-libev.git
ENV KCPTUN_URL=https://github.com/xtaci/kcptun/releases/download/v20200409/kcptun-linux-amd64-20200409.tar.gz
ENV TROJAN_URL=https://github.com/trojan-gfw/trojan.git

WORKDIR /opt
ADD . .

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' >/etc/timezone

RUN apt update 
RUN apt -y install wget curl git gcc build-essential
    # 安装 trojan 依赖库
RUN apt -y install cmake libboost-all-dev openssl libssl-dev libmysqlclient-dev
    # 安装 shadowsocks-libev 依赖库
RUN apt -y install libpcre3 libpcre3-dev libmbedtls-dev libtool asciidoc xmlto libev-dev libc-ares-dev automake libsodium-dev

# 编译 trojan
RUN git clone ${TROJAN_URL} \
    && cd trojan && cmake . && make && mv trojan /usr/local/sbin

# 编译 shadowsocks-libev
RUN git clone ${SS_LIBEV_URL} \
    && cd shadowsocks-libev \
    && git submodule update --init --recursive \
    && ./autogen.sh \
    && ./configure --prefix=/usr --disable-documentation \
    && make && make install


######################
## PRODUCTION STAGE ##
######################
FROM ubuntu:latest
LABEL maintainer "zhoubowen <zhoubowen.sky@gmail.com>"

WORKDIR /opt
ADD . .

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' >/etc/timezone

RUN apt update 
RUN apt -y install --no-install-recommends \
    # 安装 nginx
    nginx \
    # 安装 monit
    monit

# 安装 trojan
COPY --from=builder /usr/local/sbin/trojan  /usr/local/sbin/trojan
# 安装 ss
COPY --from=builder /usr/bin/ss-local       /usr/bin/
COPY --from=builder /usr/bin/ss-manager     /usr/bin/
COPY --from=builder /usr/bin/ss-nat         /usr/bin/
COPY --from=builder /usr/bin/ss-redir       /usr/bin/
COPY --from=builder /usr/bin/ss-server      /usr/bin/
COPY --from=builder /usr/bin/ss-tunnel      /usr/bin/

# 安装 kcptun
RUN cd /tmp && wget ${KCPTUN_URL} && tar -xf *.gz && mv server_linux_amd64 /usr/local/sbin/kcptun_server && rm -rf /tmp/*

# 安装 v2ray
RUN curl -L -o /tmp/go.sh https://install.direct/go.sh
RUN chmod +x /tmp/go.sh && /tmp/go.sh && rm -rf /tmp/go.sh

# 安装 monit
RUN rm -rf /etc/monit.d \
    && cp -rf monit-config/monit.d /etc/ \
    && rm -rf /etc/monitrc \
    && cp -rf monit-config/monitrc /etc/ \
    && chown root:root /etc/monitrc \
    && chmod 0700 /etc/monitrc

# copy shadowsocks kcptun and trojan configuration files
RUN cd /opt/script && chmod a+x *Console

# 启动 monit
RUN /etc/init.d/monit restart