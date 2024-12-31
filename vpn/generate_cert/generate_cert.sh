#!/bin/bash

# 检查是否以 root 权限运行
if [ "$(id -u)" -ne 0 ]; then
    echo "请使用 root 权限运行此脚本。"
    exit 1
fi

# 检查是否安装了 openssl，如果没有则自动安装
if ! command -v openssl &> /dev/null; then
    echo "未检测到 openssl，正在安装..."
    if command -v apt &> /dev/null; then
        apt update && apt install -y openssl
    elif command -v yum &> /dev/null; then
        yum install -y openssl
    else
        echo "未检测到支持的包管理器 (apt 或 yum)，请手动安装 openssl 后重试。"
        exit 1
    fi
fi

# 检查是否提供域名
if [ -z "$1" ]; then
    echo "用法: $0 <域名>"
    exit 1
fi

DOMAIN="$1"
CERT_DIR="/etc/V2bX"
FULLCHAIN="${CERT_DIR}/fullchain.cer"
KEY="${CERT_DIR}/cert.key"

# 创建存储目录（如果不存在）
mkdir -p "$CERT_DIR"

# 生成自签名证书
openssl req -x509 -newkey rsa:2048 -keyout "$KEY" -out "$FULLCHAIN" -days 365 -nodes -subj "/CN=$DOMAIN"

# 检查证书生成是否成功
if [ $? -eq 0 ]; then
    echo "证书生成成功！"
    echo "证书路径: $FULLCHAIN"
    echo "私钥路径: $KEY"
else
    echo "证书生成失败！请检查 openssl 是否已安装或查看错误日志。"
    exit 1
fi