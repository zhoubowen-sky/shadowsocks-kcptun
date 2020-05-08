##################
## BUILD STAGE1 ##
##################
FROM golang:1.14.2 AS build
LABEL maintainer "zhoubowen <zhoubowen.sky@gmail.com>"

# env
ENV SSR=https://github.com/zhoubowen-sky/shadowsocksr.git
ENV KCPTUN_URL=https://github.com/xtaci/kcptun/releases/download/v20200409/kcptun-linux-amd64-20200409.tar.gz

# download kcptun binary file
RUN cd /go/bin && wget ${KCPTUN_URL} && tar -xf *.gz && cp -f server_linux_amd64 server
# download shadowsocksr files
RUN git clone ${SSR} && cd /go/shadowsocksr && bash initcfg.sh && rm -rf .git

##################
## BUILD STAGE2 ##
##################
FROM ubuntu:latest as builder

RUN apt-get update
RUN apt-get install curl -y
RUN curl -L -o /tmp/go.sh https://install.direct/go.sh
RUN chmod +x /tmp/go.sh
RUN /tmp/go.sh

######################
## PRODUCTION STAGE ##
######################
FROM alpine:3.11.6
LABEL maintainer "zhoubowen <zhoubowen.sky@gmail.com>"

ENV SS_LIBEV_URL=https://github.com/shadowsocks/shadowsocks-libev.git
ENV TROJAN_URL=https://github.com/trojan-gfw/trojan.git

# workspace for app
WORKDIR /opt
ADD . .

RUN mkdir -p /usr/local/sbin
####################### build trojan file #######################
RUN apk add --no-cache --virtual .build-deps \
        build-base \
        cmake \
        boost-dev \
        openssl-dev \
        mariadb-connector-c-dev \
        git \
    && git clone ${TROJAN_URL} \
    && (cd trojan && cmake . && make -j $(nproc) && strip -s trojan \
    && mv trojan /usr/local/sbin) \
    && rm -rf trojan \
    && apk del .build-deps \
    && apk add --no-cache --virtual .trojan-rundeps \
        libstdc++ \
        boost-system \
        boost-program_options \
        mariadb-connector-c


# alpine update
RUN apk --no-cache update && apk --no-cache upgrade
# add start-stop-daemon and python runtime
RUN apk --no-cache add monit openrc python nginx
####################### build shadowsocks-libev binary #######################
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

####################### build v2ray binary #######################
COPY --from=builder /usr/bin/v2ray/v2ray /usr/local/sbin/v2ray/
COPY --from=builder /usr/bin/v2ray/v2ctl /usr/local/sbin/v2ray/
COPY --from=builder /usr/bin/v2ray/geoip.dat /usr/local/sbin/v2ray/
COPY --from=builder /usr/bin/v2ray/geosite.dat /usr/local/sbin/v2ray/

# copy shadowsocks shadowsocksr and kcptun binary file from build stage
COPY --from=build /go/bin/server          /usr/local/sbin/kcptun_server
COPY --from=build /go/shadowsocksr        /usr/local/sbin/shadowsocksr

# copy shadowsocks shadowsocksr kcptun and trojan configuration files
RUN cd /opt/script && chmod a+x *Console

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
