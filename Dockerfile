#
# BUILD STAGE
#
FROM golang:1.12.5 AS build
MAINTAINER zhoubowen <zhoubowen.sky@gmail.com>

# set work dir for app
WORKDIR /go
# build shadowsocks-server binary file
RUN go get -d -v github.com/shadowsocks/shadowsocks-go/cmd/shadowsocks-server
RUN go install -tags netgo -v github.com/shadowsocks/shadowsocks-go/cmd/shadowsocks-server
# build kcptun binary file
RUN go get -d -v github.com/xtaci/kcptun/server
RUN go install -tags netgo -v github.com/xtaci/kcptun/server


#
# PRODUCTION STAGE
# 
FROM alpine:3.9.4 AS prod
MAINTAINER zhoubowen <zhoubowen.sky@gmail.com>

RUN apk add monit
# add start-stop-daemon 
RUN apk add openrc

# copy shadowsocks-server binary file from build stage
RUN mkdir /usr/local/sbin
COPY --from=build /go/bin/shadowsocks-server /usr/local/sbin/shadowsocks-server
COPY --from=build /go/bin/server /usr/local/sbin/kcptun_server
# copy configuration files
RUN chmod a+x script/kcptunConsole script/shadowsocksConsole script/init_monit.start
ADD script/kcptun.json /etc/
ADD script/shadowsocks.json /etc/
ADD script/kcptunConsole /usr/local/sbin/
ADD script/shadowsocksConsole /usr/local/sbin/

# copy monit.start shell
ADD script/init_monit.start /etc/local.d/init_monit.start

# some monit files
RUN rm -rf /etc/monit.d
ADD monit-config/monit.d /etc/monit.d
ADD monit-config/monitrc /etc/monitrc

# start monit