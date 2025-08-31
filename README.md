# 安装依赖
CentOS8.x + Docker 

## 使用方法
1、安装 docker 
yum install docker

2、设置 docker 自启动
systemctl start docker
systemctl enable docker

3、将本仓库构建成本地镜像
docker build github.com/zhoubowen-sky/shadowsocks-kcptun -t v2rayimage

4、创建 docker 容器启动
docker run --privileged --name=passgfw  --restart=always -tid -v /opt/script:/opt/script  -p 80:80/udp -p 80:80/tcp  -p 443:443/udp -p 443:443/tcp v2rayimage /usr/sbin/init

5、申请域名的 ssl 证书
参见 update_certificate.sh 脚本

6、验证服务

