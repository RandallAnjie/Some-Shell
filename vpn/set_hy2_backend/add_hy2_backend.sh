#!/bin/bash

# 检查是否提供了必要的参数
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ] || [ -z "$5" ] || [ -z "$6" ] || [ -z "$7" ]; then
  echo "Usage: $0 --doname <DONAME> --cfemail <CF_Email> --cfken <CF_Key> --apihost <API_HOST> --apikey <API_KEY> --nodeid <NODE_ID> --nodeport <NODE_PORT>"
  exit 1
fi

# 解析命令行参数
while [[ $# -gt 0 ]]; do
  case $1 in
    --doname)
      DONAME="$2"
      shift 2
      ;;
    --cfemail)
      CF_Email="$2"
      shift 2
      ;;
    --cfken)
      CF_Key="$2"
      shift 2
      ;;
    --apihost)
      API_HOST="$2"
      shift 2
      ;;
    --apikey)
      API_KEY="$2"
      shift 2
      ;;
    --nodeid)
      NODE_ID="$2"
      shift 2
      ;;
    --nodeport)
      NODE_PORT="$2"
      shift 2
      ;;
    *)
      echo "Unknown parameter: $1"
      exit 1
      ;;
  esac
done

# 更新系统并安装必要的软件包
sudo apt update && sudo apt upgrade -y && sudo apt install vim wget curl net-tools socat -y

# 运行acme脚本安装acme
curl https://get.acme.sh | sh -s email="$DONAME@randallanjie.com"

# 添加或更新环境变量到.acme.sh/acme.sh.env文件
ENV_FILE="$HOME/.acme.sh/acme.sh.env"
grep -q '^export CF_Key=' $ENV_FILE && sed -i "s/^export CF_Key=.*/export CF_Key=\"$CF_Key\"/" $ENV_FILE || echo "export CF_Key=\"$CF_Key\"" >> $ENV_FILE
grep -q '^export CF_Email=' $ENV_FILE && sed -i "s/^export CF_Email=.*/export CF_Email=\"$CF_Email\"/" $ENV_FILE || echo "export CF_Email=\"$CF_Email\"" >> $ENV_FILE

# 直接导出环境变量到当前会话
export CF_Key="$CF_Key"
export CF_Email="$CF_Email"

# 设置acme并申请证书
~/.acme.sh/acme.sh --upgrade --auto-upgrade
~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
~/.acme.sh/acme.sh --issue -d "$DONAME" --dns dns_cf --dnssleep

# 创建必要的目录
sudo mkdir -p /etc/hysteria/cert

# 安装证书
~/.acme.sh/acme.sh --installcert -d "$DONAME" --key-file /etc/hysteria/cert/cert.key --fullchain-file /etc/hysteria/cert/fullchain.cer

# 创建server.yaml配置文件
sudo tee /etc/hysteria/server.yaml > /dev/null << EOF
v2board:
  apiHost: $API_HOST
  apiKey: $API_KEY
  nodeID: $NODE_ID
tls:
  type: tls
  cert: /etc/hysteria/cert/fullchain.cer
  key: /etc/hysteria/cert/cert.key
auth:
  type: v2board
trafficStats:
  listen: 0.0.0.0:$NODE_PORT
acl: 
  inline: 
    - reject(10.0.0.0/8)
    - reject(172.16.0.0/12)
    - reject(192.168.0.0/16)
    - reject(127.0.0.0/8)
    - reject(fc00::/7)
EOF

# 检测系统架构
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    HYSTERIA_URL="https://github.com/cedar2025/hysteria/releases/download/app%2Fv1.0.3/hysteria-linux-amd64"
elif [ "$ARCH" = "aarch64" ]; then
    HYSTERIA_URL="https://github.com/cedar2025/hysteria/releases/download/app%2Fv1.0.3/hysteria-linux-arm64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

# 下载hysteria
sudo wget -O /etc/hysteria/hysteriabackend "$HYSTERIA_URL"
sudo chmod +x /etc/hysteria/hysteriabackend

# 创建systemd服务文件
sudo tee /lib/systemd/system/hy2backend.service > /dev/null << EOF
[Unit]
Description = v2board hy2 backend
After = network.target syslog.target
Wants = network.target

[Service]
Type = simple
WorkingDirectory = /etc/hysteria/
ExecStart = /etc/hysteria/hysteriabackend server -c /etc/hysteria/server.yaml

[Install]
WantedBy = multi-user.target
EOF

# 重新加载systemd并启动服务
sudo systemctl daemon-reload
sudo systemctl enable hy2backend
sudo systemctl start hy2backend

echo "Setup complete for $DONAME"

