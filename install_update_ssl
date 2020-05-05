#!/bin/sh

# 1 install acme.sh
curl  https://get.acme.sh | sh

# 2 create acme.sh alias
echo 'alias acme.sh=~/.acme.sh/acme.sh' >> /etc/profile
source /etc/profile

# 3 v2ray ssl file www.biutefor.icu
acme.sh --renew -d www.biutefor.icu --yes-I-know-dns-manual-mode-enough-go-ahead-please
slppe 1
acme.sh --install-cert -d www.biutefor.icu --key-file /opt/script/mydomain.key --fullchain-file /opt/script/mydomain.pem --reloadcmd  "service nginx force-reload"

# 4 trojan ssl file biutefor.icu
acme.sh --renew -d biutefor.icu --yes-I-know-dns-manual-mode-enough-go-ahead-please
sleep 1
acme.sh --install-cert -d biutefor.icu --key-file /opt/script/mydomain_no3w.key --fullchain-file /opt/script/mydomain_no3w.pem --reloadcmd  "service nginx force-reload"

# 5 restart docker container
docker restart passgfw

