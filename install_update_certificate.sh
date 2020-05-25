#!/bin/sh

# 申请通配符证书

# 1 安装 acme.sh
curl  https://get.acme.sh | sh

# 2 创建 acme.sh alias
echo 'alias acme.sh=~/.acme.sh/acme.sh' >> /etc/profile
source /etc/profile

# 申请证书 自动DNS验证命令
acme.sh --issue --dns dns_cf -d biutefor.icu -d *.biutefor.icu
# 申请证书 手动DNS验证命令
acme.sh --issue -d biutefor.icu -d *.biutefor.icu --yes-I-know-dns-manual-mode-enough-go-ahead-please

# 重新申请证书 
acme.sh --renew --dns dns_cf -d biutefor.icu -d *.biutefor.icu

# 安装证书
acme.sh --install-cert -d biutefor.icu --key-file /opt/script/mydomain.key --fullchain-file /opt/script/mydomain.pem --reloadcmd "systemctl restart docker"

# 5 restart docker container
docker restart passgfw

