#!/bin/sh

# 1 安装 acme.sh
curl  https://get.acme.sh | sh

# 2 创建 acme.sh alias
echo 'alias acme.sh=~/.acme.sh/acme.sh' >> /etc/profile
source /etc/profile

#  3 申请证书
acme.sh --issue --dns dns_cf -d www.zhoubowen.vip --force

# 4 安装证书
acme.sh --install-cert -d www.zhoubowen.vip --key-file /opt/script/mydomain.key --fullchain-file /opt/script/mydomain.pem

# 5 重启 docker 服务加载证书
docker restart passgfw

