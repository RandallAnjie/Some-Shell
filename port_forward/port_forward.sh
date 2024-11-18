#!/bin/bash

# Function to add port forwarding rule
add_port_forwarding() {
    local protocol=$1
    local src_port=$2
    local dest_ip=$3
    local dest_port=$4

    # Add the port forwarding rule
    iptables -t nat -A PREROUTING -p tcp --dport $src_port -j DNAT --to-destination $dest_ip:$dest_port
    iptables -t nat -A POSTROUTING -p tcp -d $dest_ip --dport $dest_port -j MASQUERADE

    echo "Port forwarding added: $src_port -> $dest_ip:$dest_port"
}

# Function to list port forwarding rules
list_port_forwarding() {
    echo "Current port forwarding rules:"
    iptables -t nat -L PREROUTING -n -v --line-numbers
}

# Main script logic
if [ "$1" == "add" ] && [ "$2" == "ipv4" ]; then
    add_port_forwarding "tcp" $3 $4 $5
elif [ "$1" == "list" ]; then
    list_port_forwarding
else
    echo "Usage: $0 add ipv4 <src_port> <dest_ip> <dest_port>"
    echo "       $0 list"
fi