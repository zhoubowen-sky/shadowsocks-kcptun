
######################
## PRODUCTION STAGE ##
######################
FROM centos:7
LABEL maintainer "xxx@xxx.com"

ENV V2RAY_URL=https://github.com/v2fly/v2ray-core/releases/download/v4.45.2/v2ray-linux-64.zip

WORKDIR /opt
ADD . .

# 设定时区
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' >/etc/timezone \
# 安装基础工具
    && yum -y install wget curl unzip xz-utils \
# 安装 nginx
    && rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm \
    && yum -y install nginx \
# 安装 monit
    && yum -y install epel-release \
    && yum -y install monit \

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
    # && rm -rf .git doc trojan* v2ray* kcptun-linux* client_linux* server_linux* \
# 给脚本可执行权限
    && cd /opt/script && chmod a+x *Console
    # 删除缓存及无用的软件
    # && yum -y remove wget unzip && yum clean all 
