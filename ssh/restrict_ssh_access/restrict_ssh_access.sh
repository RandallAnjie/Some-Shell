#!/bin/bash

# 获取命令行参数
while getopts "4:6:" opt; do
  case $opt in
    4) ALLOWED_IPV4="$OPTARG"
    ;;
    6) ALLOWED_IPV6="$OPTARG"
    ;;
    \?) echo "无效的参数: -$OPTARG" >&2
        exit 1
    ;;
  esac
done

# 检查是否提供了IP地址
if [ -z "$ALLOWED_IPV4" ] && [ -z "$ALLOWED_IPV6" ]; then
    echo "必须指定IPv4或IPv6地址"
    exit 1
fi

# 更新包管理器并安装 iptables-persistent 以便在重启后保存规则
install_iptables() {
    echo "正在安装iptables..."
    apt-get update
    apt-get install -y iptables ip6tables iptables-persistent
}

# 配置 ufw
configure_ufw() {
    echo "配置ufw规则"
    
    # 移除现有的22端口规则
    ufw delete allow 22/tcp
    
    # 允许指定IP地址访问22端口
    if [ -n "$ALLOWED_IPV4" ]; then
        ufw allow from $ALLOWED_IPV4 to any port 22 proto tcp
    fi
    if [ -n "$ALLOWED_IPV6" ]; then
        ufw allow from $ALLOWED_IPV6 to any port 22 proto tcp
    fi

    # 启用ufw
    ufw reload

    # 显示当前的ufw状态
    ufw status verbose
}

# 配置 iptables
configure_iptables() {
    echo "配置iptables规则"
    
    # 移除现有的22端口规则
    iptables -D INPUT -p tcp --dport 22 -j ACCEPT
    ip6tables -D INPUT -p tcp --dport 22 -j ACCEPT

    # 允许指定IP地址访问22端口
    if [ -n "$ALLOWED_IPV4" ]; then
        iptables -A INPUT -p tcp -s $ALLOWED_IPV4 --dport 22 -j ACCEPT
    fi
    if [ -n "$ALLOWED_IPV6" ]; then
        ip6tables -A INPUT -p tcp -s $ALLOWED_IPV6 --dport 22 -j ACCEPT
    fi

    # 保存iptables规则
    iptables-save > /etc/iptables/rules.v4
    ip6tables-save > /etc/iptables/rules.v6

    # 使规则在重启后生效
    netfilter-persistent save
    netfilter-persistent reload
}

# 检查是否安装了ufw或iptables
if command -v ufw &> /dev/null
then
    configure_ufw

elif command -v iptables &> /dev/null
then
    configure_iptables

else
    echo "没有安装ufw或iptables，正在安装iptables..."
    install_iptables
    configure_iptables
fi

echo "防火墙规则配置完成"
