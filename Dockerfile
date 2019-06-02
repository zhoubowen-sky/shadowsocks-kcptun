#
# BUILD STAGE
#
FROM golang:1.12.5 AS build

LABEL maintainer "zhoubowen <zhoubowen.sky@gmail.com>"

# set work dir for app
WORKDIR /go
# build shadowsocks-server binary file
RUN go get -d -v github.com/shadowsocks/shadowsocks-go/cmd/shadowsocks-server \
    && go install -tags netgo -v github.com/shadowsocks/shadowsocks-go/cmd/shadowsocks-server
# build kcptun binary file
RUN go get -d -v github.com/xtaci/kcptun/server \
    && go install -tags netgo -v github.com/xtaci/kcptun/server


#
# PRODUCTION STAGE
# 
FROM alpine:3.9.4 AS prod

LABEL maintainer "zhoubowen <zhoubowen.sky@gmail.com>"

# set work dir for app
WORKDIR /opt
ADD . .

# add start-stop-daemon 
RUN apk update \
    && apk upgrade \
    && apk add --no-cach monit \
    && apk add --no-cach openrc \
    && rm -rf /var/cache/apk/*

# copy shadowsocks and kcptun binary file from build stage
RUN mkdir /usr/local/sbin
COPY --from=build /go/bin/shadowsocks-server /usr/local/sbin/shadowsocks-server
COPY --from=build /go/bin/server /usr/local/sbin/kcptun_server

# copy shadowsocks and kcptun configuration files
RUN cp -rf script/kcptun.json /etc/ \
    && cp -rf script/shadowsocks.json /etc/ \
    && cp -rf script/kcptunConsole /usr/local/sbin/ \
    && cp -rf script/shadowsocksConsole /usr/local/sbin/
RUN chmod a+x /usr/local/sbin/kcptunConsole /usr/local/sbin/shadowsocksConsole

# copy some monit configuration files
RUN rm -rf /etc/monit.d \
    && cp -rf monit-config/monit.d /etc/ \
    && rm -rf /etc/monitrc \
    && cp -rf monit-config/monitrc /etc/
RUN chown root:root /etc/monitrc && chmod 0700 /etc/monitrc

# set monit boot up 
RUN rc-update add monit 
