#!/bin/bash

# 定义源列表
declare -A sources=(
    ["Ubuntu"]="official:archive.ubuntu.com/ubuntu/ tsinghua:mirrors.tuna.tsinghua.edu.cn/ubuntu/ alibaba:mirrors.aliyun.com/ubuntu/ ustc:mirrors.ustc.edu.cn/ubuntu/"
    ["Debian"]="official:deb.debian.org/debian tsinghua:mirrors.tuna.tsinghua.edu.cn/debian/ alibaba:mirrors.aliyun.com/debian/ ustc:mirrors.ustc.edu.cn/debian/"
    ["CentOS"]="official:mirror.centos.org/centos tsinghua:mirrors.tuna.tsinghua.edu.cn/centos/ alibaba:mirrors.aliyun.com/centos/ ustc:mirrors.ustc.edu.cn/centos/"
)

# 函数：获取和验证系统版本
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        VERSION=$VERSION_ID
    elif [ -f /etc/centos-release ]; then
        DISTRO="centos"
        VERSION=$(cut -d' ' -f4 /etc/centos-release)
    else
        echo "无法识别当前系统版本。"
        exit 1
    fi
}

# 函数：显示源选择菜单
display_source_menu() {
    echo "选择源："
    echo "1. 官方"
    echo "2. 清华"
    echo "3. 阿里云"
    echo "4. 科大"
    read -p "请输入数字选择源 (默认1): " choice
    choice=${choice:-1}
    case $choice in
        1) echo "official";;
        2) echo "tsinghua";;
        3) echo "alibaba";;
        4) echo "ustc";;
        *) echo "official";;
    esac
}

# 函数：替换源配置文件
update_source() {
    local DISTRO=$1
    local SOURCE=$2
    local VERSION=$3

    case $DISTRO in
        "ubuntu")
            sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup
            if [ "$SOURCE" = "official" ]; then
                echo "deb http://archive.ubuntu.com/ubuntu/ $VERSION main restricted universe multiverse" | sudo tee /etc/apt/sources.list
            else
                echo "deb http://${sources[$DISTRO,$SOURCE]} $VERSION main restricted universe multiverse" | sudo tee /etc/apt/sources.list
            fi
            sudo apt-get update
        ;;
        "debian")
            sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup
            if [ "$SOURCE" = "official" ]; then
                echo "deb http://deb.debian.org/debian $VERSION main contrib non-free" | sudo tee /etc/apt/sources.list
            else
                echo "deb http://${sources[$DISTRO,$SOURCE]} $VERSION main contrib non-free" | sudo tee /etc/apt/sources.list
            fi
            sudo apt-get update
        ;;
        "centos")
            sudo cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
            if [ "$SOURCE" = "official" ]; then
                sudo sed -i "s|^mirrorlist=|#mirrorlist=|" /etc/yum.repos.d/CentOS-Base.repo
                sudo sed -i "s|^#baseurl=http://mirror.centos.org|baseurl=http://mirror.centos.org|" /etc/yum.repos.d/CentOS-Base.repo
            else
                sudo sed -i "s|^mirrorlist=|#mirrorlist=|" /etc/yum.repos.d/CentOS-Base.repo
                sudo sed -i "s|^#baseurl=http://mirror.centos.org|baseurl=http://${sources[$DISTRO,$SOURCE]}|" /etc/yum.repos.d/CentOS-Base.repo
            fi
            sudo yum clean all && sudo yum makecache
        ;;
    esac
    echo "源已更新为 $SOURCE 源。"
}

# 主逻辑
detect_distro
SOURCE=$(display_source_menu)
update_source $DISTRO $SOURCE $VERSION