#!/bin/bash

# 添加端口转发的函数
add_forwarding() {
  local proto=$1
  local external_port=$2
  local internal_ip=$3
  local internal_port=$4

  if [ "$proto" == "ipv4" ]; then
    iptables -t nat -A PREROUTING -p tcp --dport $external_port -j DNAT --to-destination $internal_ip:$internal_port
    iptables -A FORWARD -p tcp -d $internal_ip --dport $internal_port -j ACCEPT
    echo "已添加 IPv4 转发: $external_port -> $internal_ip:$internal_port"
  elif [ "$proto" == "ipv6" ]; then
    ip6tables -t nat -A PREROUTING -p tcp --dport $external_port -j DNAT --to-destination [$internal_ip]:$internal_port
    ip6tables -A FORWARD -p tcp -d $internal_ip --dport $internal_port -j ACCEPT
    echo "已添加 IPv6 转发: $external_port -> $internal_ip:$internal_port"
  else
    echo "无效的协议。请使用 'ipv4' 或 'ipv6'。"
  fi
}

# 删除端口转发的函数
delete_forwarding() {
  local proto=$1
  local external_port=$2

  if [ "$proto" == "ipv4" ]; then
    iptables -t nat -D PREROUTING -p tcp --dport $external_port -j DNAT
    iptables -D FORWARD -p tcp --dport $external_port -j ACCEPT
    echo "已删除 IPv4 转发: $external_port"
  elif [ "$proto" == "ipv6" ]; then
    ip6tables -t nat -D PREROUTING -p tcp --dport $external_port -j DNAT
    ip6tables -D FORWARD -p tcp --dport $external_port -j ACCEPT
    echo "已删除 IPv6 转发: $external_port"
  else
    echo "无效的协议。请使用 'ipv4' 或 'ipv6'。"
  fi
}

# 列出当前端口转发的函数
list_forwardings() {
  echo "IPv4 转发:"
  iptables -t nat -L PREROUTING -v -n
  echo ""
  echo "IPv6 转发:"
  ip6tables -t nat -L PREROUTING -v -n
}

# 修改端口转发的函数
modify_forwarding() {
  local proto=$1
  local old_external_port=$2
  local new_external_port=$3
  local internal_ip=$4
  local internal_port=$5

  # 删除旧的转发规则
  delete_forwarding $proto $old_external_port

  # 添加新的转发规则
  add_forwarding $proto $new_external_port $internal_ip $internal_port
}

# 显示用法信息
usage() {
  echo "用法: $0 {add|delete|modify|list} [选项]"
  echo "命令:"
  echo "  add <ipv4|ipv6> <外部端口> <内部IP> <内部端口>"
  echo "  delete <ipv4|ipv6> <外部端口>"
  echo "  modify <ipv4|ipv6> <旧外部端口> <新外部端口> <内部IP> <内部端口>"
  echo "  list"
}

# 主脚本逻辑
if [ $# -lt 1 ]; then
  usage
  exit 1
fi

command=$1
shift

case "$command" in
  add)
    if [ $# -ne 4 ]; then
      usage
      exit 1
    fi
    add_forwarding "$@"
    ;;
  delete)
    if [ $# -ne 2 ]; then
      usage
      exit 1
    fi
    delete_forwarding "$@"
    ;;
  modify)
    if [ $# -ne 5 ]; then
      usage
      exit 1
    fi
    modify_forwarding "$@"
    ;;
  list)
    list_forwardings
    ;;
  *)
    usage
    exit 1
    ;;
esac