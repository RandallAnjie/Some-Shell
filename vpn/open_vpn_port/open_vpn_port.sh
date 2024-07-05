#!/bin/bash

# 更新包管理器并安装 iptables-persistent 以便在重启后保存规则
install_iptables() {
    echo "正在安装iptables..."
    apt-get update
    apt-get install -y iptables ip6tables iptables-persistent
}

# 配置 ufw
configure_ufw() {
    echo "配置ufw规则"

    # 允许所有IP访问2087, 2088, 2089端口，使用TCP和UDP协议
    for port in 2087 2088 2089; do
        ufw allow $port/tcp
        ufw allow $port/udp
    done

    # 启用ufw
    ufw reload

    # 显示当前的ufw状态
    ufw status verbose
}

# 配置 iptables
configure_iptables() {
    echo "配置iptables规则"

    # 允许所有IP访问2087, 2088, 2089端口，使用TCP和UDP协议
    for port in 2087 2088 2089; do
        iptables -A INPUT -p tcp --dport $port -j ACCEPT
        iptables -A INPUT -p udp --dport $port -j ACCEPT
        ip6tables -A INPUT -p tcp --dport $port -j ACCEPT
        ip6tables -A INPUT -p udp --dport $port -j ACCEPT
    done

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
