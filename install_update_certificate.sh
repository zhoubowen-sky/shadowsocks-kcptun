#!/bin/sh

# 申请通配符证书

# 1 install acme.sh
curl  https://get.acme.sh | sh

# 2 create acme.sh alias
echo 'alias acme.sh=~/.acme.sh/acme.sh' >> /etc/profile
source /etc/profile

# 3 自动DNS命令
acme.sh --issue --dns dns_cf -d biutefor.icu -d *.biutefor.icu
# 手动DNS命令
#
acme.sh --renew -d biutefor.icu -d *.biutefor.icu --yes-I-know-dns-manual-mode-enough-go-ahead-please
slppe 1
acme.sh --install-cert -d biutefor.icu --key-file /opt/script/mydomain.key --fullchain-file /opt/script/mydomain.pem --reloadcmd  "service nginx force-reload"

# 5 restart docker container
docker restart passgfw

