#################
## BUILD STAGE ##
#################
FROM golang:1.12.6 AS build
LABEL maintainer "zhoubowen <zhoubowen.sky@gmail.com>"

# some 
ENV SSR=https://github.com/zhoubowen-sky/shadowsocksr.git
ENV GOSS2=github.com/zhoubowen-sky/go-shadowsocks2
ENV KCPTUN_URL=https://github.com/xtaci/kcptun/releases/download/v20190611/kcptun-linux-amd64-20190611.tar.gz
ENV BROOK_URL=https://github.com/txthinking/brook/releases/download/v20190601/brook

# kcptun binary file
RUN cd /go/bin && wget ${KCPTUN_URL} && tar -xf *.gz && cp -f server_linux_amd64 server
# brook binary file
RUN cd /go/bin && wget ${BROOK_URL} && chmod a+x brook
# build go-shadowsocks2 binary file
RUN go get -d -v ${GOSS2} && go install -ldflags '-w -s' -tags netgo -v ${GOSS2}
# download shadowsocksr 
RUN git clone ${SSR} && cd /go/shadowsocksr && bash initcfg.sh && rm -rf .git

######################
## PRODUCTION STAGE ##
######################
FROM alpine:3.10.0
LABEL maintainer "zhoubowen <zhoubowen.sky@gmail.com>"

# time zone
ARG TZ='Asia/Shanghai'
ENV TZ ${TZ}
RUN ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone

# workspace for app
WORKDIR /opt
ADD . .

# add start-stop-daemon 
RUN apk --no-cache add monit openrc python

# copy shadowsocks、brook shadowsocksr and kcptun binary file from build stage
RUN mkdir -p /usr/local/sbin
COPY --from=build /go/bin/server /usr/local/sbin/kcptun_server
COPY --from=build /go/bin/go-shadowsocks2 /usr/local/sbin/go-shadowsocks2
COPY --from=build /go/shadowsocksr /usr/local/sbin/shadowsocksr
COPY --from=build /go/bin/brook /usr/local/sbin/brook

# copy shadowsocks shadowsocksr and kcptun configuration files
RUN cp -rf script/kcptun.json /etc/ \
    && cp -rf script/shadowsocks.json /etc/ \
    && cp -rf script/shadowsocksr.json /etc/ \
    && cp -rf script/kcptunConsole /usr/local/sbin/ \
    && cp -rf script/shadowsocks2Console /usr/local/sbin/ \
    && cp -rf script/shadowsocksRConsole /usr/local/sbin/ \
    && cp -rf script/brookConsole /usr/local/sbin/ \
    && chmod a+x /usr/local/sbin/kcptunConsole \
    /usr/local/sbin/shadowsocks2Console \
    /usr/local/sbin/shadowsocksRConsole \
    /usr/local/sbin/brookConsole

# copy monit configuration files
RUN rm -rf /etc/monit.d \
    && cp -rf monit-config/monit.d /etc/ \
    && rm -rf /etc/monitrc \
    && cp -rf monit-config/monitrc /etc/ \
    && chown root:root /etc/monitrc \
    && chmod 0700 /etc/monitrc

# set monit boot up 
RUN rc-update add monit 
