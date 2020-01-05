
######################
## PRODUCTION STAGE ##
######################
FROM alpine:3.11.2
LABEL maintainer "zhoubowen <zhoubowen.sky@gmail.com>"

# workspace for app
WORKDIR /opt
ADD . .

ENV SSR=https://github.com/zhoubowen-sky/shadowsocksr.git
ENV KCPTUN_URL=https://github.com/xtaci/kcptun/releases/download/v20200103/kcptun-linux-amd64-20200103.tar.gz
ENV BROOK_URL=https://github.com/txthinking/brook/releases/download/v20200102/brook
ENV TROJAN_URL=https://github.com/trojan-gfw/trojan/releases/download/v1.14.0/trojan-1.14.0-linux-amd64.tar.xz
ENV SS_LIBEV_URL=https://github.com/shadowsocks/shadowsocks-libev.git

RUN apk add git
# download kcptun binary file
RUN wget ${KCPTUN_URL} && tar -xf *.gz && cp -f server_linux_amd64 server
# download brook binary file
RUN wget ${BROOK_URL} && chmod a+x brook
# download shadowsocksr files
RUN git clone ${SSR} && cd shadowsocksr && bash initcfg.sh && rm -rf .git
# download trojan file
RUN wget ${TROJAN_URL}
RUN xz *.xz 
RUN tar -xvf *.tar 
RUN cp -f trojan/trojan trojan_server



# alpine update
RUN apk --no-cache update && apk --no-cache upgrade
# add start-stop-daemon and python runtime
RUN apk --no-cache add monit openrc python
# build shadowsocks-libev binary
RUN apk add --no-cache --virtual .build-deps \
    autoconf \
    automake \
    build-base \
    git \
    c-ares-dev \
    libev-dev \
    libtool \
    libsodium-dev \
    linux-headers \
    mbedtls-dev \
    pcre-dev \
    # build binary and install
    && git clone ${SS_LIBEV_URL} \
    && cd shadowsocks-libev \
    && git submodule update --init --recursive \
    && ./autogen.sh \
    && ./configure --prefix=/usr --disable-documentation \
    && make install \
    && apk del .build-deps \
    # add shadowsocks-libev runtime dependencies
    && apk add --no-cache \
      rng-tools \
      $(scanelf --needed --nobanner /usr/bin/ss-* \
      | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
      | sort -u) \
    && rm -rf /opt/shadowsocks-libev/

# copy shadowsocks brook shadowsocksr and kcptun binary file from build stage
RUN mkdir -p /usr/local/sbin
COPY --from=build /opt/server          /usr/local/sbin/kcptun_server
COPY --from=build /opt/shadowsocksr    /usr/local/sbin/shadowsocksr
COPY --from=build /opt/brook           /usr/local/sbin/brook
COPY --from=build /opt/trojan_server   /usr/local/sbin/trojan

# copy shadowsocks shadowsocksr kcptun and trojan configuration files
RUN cp -rf script/kcptun.json /etc/ \
    && cp -rf script/shadowsocks.json /etc/ \
    && cp -rf script/shadowsocksr.json /etc/ \
    && cp -rf script/trojan_server.json /etc/ \
    && cp -rf script/kcptunConsole /usr/local/sbin/ \
    && cp -rf script/shadowsocksRConsole /usr/local/sbin/ \
    && cp -rf script/shadowsocksLibevConsole /usr/local/sbin/ \
    && cp -rf script/brookConsole /usr/local/sbin/ \
    && cp -rf script/trojanConsole /usr/local/sbin/ \
    && chmod a+x /usr/local/sbin/kcptunConsole \
    /usr/local/sbin/shadowsocksRConsole \
    /usr/local/sbin/brookConsole \
    /usr/local/sbin/trojanConsole \
    /usr/local/sbin/shadowsocksLibevConsole

# remove unused files
RUN rm -rf .git .gitignore doc

# copy monit configuration files
RUN rm -rf /etc/monit.d \
    && cp -rf monit-config/monit.d /etc/ \
    && rm -rf /etc/monitrc \
    && cp -rf monit-config/monitrc /etc/ \
    && chown root:root /etc/monitrc \
    && chmod 0700 /etc/monitrc

# set monit boot up 
RUN rc-update add monit 
