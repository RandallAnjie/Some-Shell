#!/bin/bash

# 1. 默认参数初始化
SERVER_TYPE=""
NODE_ID=""
SOGA_KEY=""
WEBAPI_URL=""
WEBAPI_KEY=""
CERT_DOMAIN=""
CERT_KEY_LENGTH="ec-256"
DNS_PROVIDER="dns_cf"
DNS_CF_EMAIL=""
DNS_CF_KEY=""

# 2. 解析外部传入的参数
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --server_type) SERVER_TYPE="$2"; shift ;;
        --node_id) NODE_ID="$2"; shift ;;
        --soga_key) SOGA_KEY="$2"; shift ;;
        --webapi_url) WEBAPI_URL="$2"; shift ;;
        --webapi_key) WEBAPI_KEY="$2"; shift ;;
        --cert_domain) CERT_DOMAIN="$2"; shift ;;
        --cert_key_length) CERT_KEY_LENGTH="$2"; shift ;;
        --dns_provider) DNS_PROVIDER="$2"; shift ;;
        --DNS_CF_Email) DNS_CF_EMAIL="$2"; shift ;;
        --DNS_CF_Key) DNS_CF_KEY="$2"; shift ;;
        *) echo "未知参数: $1"; exit 1 ;;
    esac
    shift
done

# 验证必填参数是否已提供 (可根据需要调整)
if [[ -z "$SERVER_TYPE" || -z "$NODE_ID" || -z "$SOGA_KEY" || -z "$WEBAPI_URL" ]]; then
    echo "错误: 缺少必要的参数配置。请确保传入了 --server_type, --node_id, --soga_key, --webapi_url 等参数。"
    exit 1
fi

echo "开始更新系统并安装基础组件..."
sudo apt update && sudo apt upgrade -y
sudo apt install vim wget curl net-tools -y

echo "开始配置系统内核参数..."
# 将内核参数追加到 /etc/sysctl.conf
cat <<EOF >> /etc/sysctl.conf

# === Soga Network Optimization ===
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_rmem = 16384 16777216 536870912
net.ipv4.tcp_wmem = 16384 16777216 536870912
net.ipv4.udp_mem = 16777216 33554432 67108864
net.ipv4.tcp_adv_win_scale = -2
net.ipv4.tcp_sack = 1
net.ipv4.tcp_notsent_lowat = 131072
net.ipv4.ip_local_port_range = 1024 65535
net.core.rmem_max = 536870912
net.core.rmem_default=268435456
net.core.wmem_max = 536870912
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 65535
net.ipv4.tcp_max_tw_buckets = 65536
net.ipv4.tcp_abort_on_overflow = 1
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_syncookies = 0
net.ipv4.tcp_syn_retries = 3
net.ipv4.tcp_synack_retries = 3
net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_keepalive_intvl = 3
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_retries1 = 3
net.ipv4.tcp_retries2 = 5
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_tw_reuse = 1
fs.file-max = 104857600
fs.inotify.max_user_instances = 8192
fs.nr_open = 1048576
kernel.panic = -1
vm.swappiness = 20
# =================================
EOF

# 使内核参数生效
sysctl -p

echo "开始安装 Soga..."
bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/soga/master/install.sh)

echo "配置 Soga..."
# 确保配置目录存在
mkdir -p /etc/soga/

# 生成配置文件
cat <<EOF > /etc/soga/soga.conf
# 基础配置
type=xboard
server_type=${SERVER_TYPE}
node_id=${NODE_ID}
soga_key=${SOGA_KEY}
listen=all
# webapi 或 db 对接任选一个
api=webapi
# webapi 对接信息
webapi_url=${WEBAPI_URL}
webapi_key=${WEBAPI_KEY}
# db 对接信息
db_host=
db_port=
db_name=
db_user=
db_password=
# 手动证书配置
cert_file=
key_file=
# 自动证书配置
cert_mode=dns
cert_domain=${CERT_DOMAIN}
cert_key_length=${CERT_KEY_LENGTH}
dns_provider=${DNS_PROVIDER}
DNS_CF_Email=${DNS_CF_EMAIL}
DNS_CF_Key=${DNS_CF_KEY}
# proxy protocol 中转配置
proxy_protocol=false
udp_proxy_protocol=false
# 全局限制用户 IP 数配置
redis_enable=false
redis_addr=
redis_password=
redis_db=0
conn_limit_expiry=60
# 动态限速配置
dy_limit_enable=false
dy_limit_duration=
dy_limit_trigger_time=60
dy_limit_trigger_speed=100
dy_limit_speed=30
dy_limit_time=600
dy_limit_white_user_id=
# 其它杂项
user_conn_limit=0
user_speed_limit=0
user_tcp_limit=0
node_speed_limit=0
check_interval=60
submit_interval=60
forbidden_bit_torrent=true
log_level=error
geo_update_enable=true
EOF

echo "重启 Soga 服务..."
soga restart

echo "部署完成！您可以使用 'soga log' 命令查看运行日志。"
