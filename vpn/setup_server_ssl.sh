#!/bin/bash

# 检查是否提供了必要的参数
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
  echo "Usage: $0 <DONAMEFRONT> <CF_Key> <CF_Email>"
  exit 1
fi

# 变量
DONAMEFRONT="$1"
CF_Key="$2"
CF_Email="$3"
DONAMEEND="$4"

# 更新系统并安装必要的软件包
sudo apt update && sudo apt upgrade -y && sudo apt install vim wget curl net-tools socat -y

# 设置主机名
sudo hostnamectl set-hostname "$DONAMEFRONT.$DONAMEEND"

# 运行acme脚本安装acme
curl https://get.acme.sh | sh -s email="$DONAMEFRONT@$DONAMEEND"

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
~/.acme.sh/acme.sh --issue -d "$DONAMEFRONT.$DONAMEEND" -d "$DONAMEFRONT-cf.$DONAMEEND" --dns dns_cf --dnssleep

~/.acme.sh/acme.sh --installcert -d "$DONAMEFRONT.$DONAMEEND" --key-file /etc/V2bX/cert.key --fullchain-file /etc/V2bX/fullchain.cer --reloadcmd "v2bx restart"

echo "Setup complete for $DONAMEFRONT.$DONAMEEND"

wget -N https://raw.githubusercontent.com/wyx2685/V2bX-script/master/install.sh && bash install.sh

