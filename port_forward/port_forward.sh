#!/bin/bash

# Function to check and enable IP forwarding
check_and_enable_ip_forwarding() {
    local protocol=$1
    if [ "$protocol" == "ipv4" ]; then
        local ip_forwarding=$(sysctl -n net.ipv4.ip_forward)
        if [ "$ip_forwarding" -ne 1 ]; then
            echo "Enabling IPv4 forwarding..."
            sysctl -w net.ipv4.ip_forward=1
        else
            echo "IPv4 forwarding is already enabled."
        fi
    elif [ "$protocol" == "ipv6" ]; then
        local ip_forwarding=$(sysctl -n net.ipv6.conf.all.forwarding)
        if [ "$ip_forwarding" -ne 1 ]; then
            echo "Enabling IPv6 forwarding..."
            sysctl -w net.ipv6.conf.all.forwarding=1
        else
            echo "IPv6 forwarding is already enabled."
        fi
    fi
}

# Function to add port forwarding rule
add_port_forwarding() {
    local protocol=$1
    local src_port=$2
    local dest_ip=$3
    local dest_port=$4

    # Check and enable IP forwarding
    check_and_enable_ip_forwarding $protocol

    # Add the port forwarding rule
    if [ "$protocol" == "ipv4" ]; then
        iptables -t nat -A PREROUTING -p tcp --dport $src_port -j DNAT --to-destination $dest_ip:$dest_port
        iptables -t nat -A POSTROUTING -p tcp -d $dest_ip --dport $dest_port -j MASQUERADE
    elif [ "$protocol" == "ipv6" ]; then
        ip6tables -t nat -A PREROUTING -p tcp --dport $src_port -j DNAT --to-destination [$dest_ip]:$dest_port
        ip6tables -t nat -A POSTROUTING -p tcp -d $dest_ip --dport $dest_port -j MASQUERADE
    fi

    echo "Port forwarding added: $src_port -> $dest_ip:$dest_port"
}

# Function to delete port forwarding rule
delete_port_forwarding() {
    local protocol=$1
    local src_port=$2
    local dest_ip=$3
    local dest_port=$4

    # Delete the port forwarding rule
    if [ "$protocol" == "ipv4" ]; then
        iptables -t nat -D PREROUTING -p tcp --dport $src_port -j DNAT --to-destination $dest_ip:$dest_port
        iptables -t nat -D POSTROUTING -p tcp -d $dest_ip --dport $dest_port -j MASQUERADE
    elif [ "$protocol" == "ipv6" ]; then
        ip6tables -t nat -D PREROUTING -p tcp --dport $src_port -j DNAT --to-destination [$dest_ip]:$dest_port
        ip6tables -t nat -D POSTROUTING -p tcp -d $dest_ip --dport $dest_port -j MASQUERADE
    fi

    echo "Port forwarding deleted: $src_port -> $dest_ip:$dest_port"
}

# Function to list port forwarding rules
list_port_forwarding() {
    echo "Current port forwarding rules:"
    iptables -t nat -L PREROUTING -n -v --line-numbers
    ip6tables -t nat -L PREROUTING -n -v --line-numbers
}

# Main script logic
if [ "$1" == "add" ]; then
    add_port_forwarding $2 $3 $4 $5
elif [ "$1" == "delete" ]; then
    delete_port_forwarding $2 $3 $4 $5
elif [ "$1" == "list" ]; then
    list_port_forwarding
else
    echo "Usage: $0 add <ipv4|ipv6> <src_port> <dest_ip> <dest_port>"
    echo "       $0 delete <ipv4|ipv6> <src_port> <dest_ip> <dest_port>"
    echo "       $0 list"
fi