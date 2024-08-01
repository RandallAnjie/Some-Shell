#!/bin/bash

# 处理参数
while getopts ":b:c:l:" opt; do
  case $opt in
    b) hash_value="$OPTARG" ;;
    c) charset_option="$OPTARG" ;;
    l) max_length="$OPTARG" ;;
    \?) echo "Invalid option -$OPTARG" >&2; exit 1 ;;
    :) echo "Option -$OPTARG requires an argument." >&2; exit 1 ;;
  esac
done

# 检查参数
if [ -z "$hash_value" ] || [ -z "$charset_option" ] || [ -z "$max_length" ]; then
    echo "用法: $0 -b <hash_value> -c <charset_option> -l <max_length>"
    echo "  charset_option: 1 (包含特殊字符) 或 2 (不包含特殊字符)"
    exit 1
fi

# 设置字符集
if [ "$charset_option" == "1" ]; then
    charset='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-=[]{}|;:,.<>?/~`'
elif [ "$charset_option" == "2" ]; then
    charset='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
else
    echo "无效的 charset_option"
    exit 1
fi

# 计算总组合数
total_combinations=$((0))
for length in $(seq 1 $max_length); do
    total_combinations=$((total_combinations + ${#charset}**length))
done

start_time=$(date +%s)
attempts=0

for length in $(seq 1 $max_length); do
    # 生成密码组合时使用seq和tr来避免eval
    for guess in $(seq 1 $length | tr '1-9' "$charset"); do
        attempts=$((attempts + 1))
        if echo -n "$guess" | bcrypt "$hash_value" &> /dev/null; then
            end_time=$(date +%s)
            elapsed_time=$((end_time - start_time))
            echo -e "\n找到匹配的密码: $guess (尝试次数: $attempts, 耗时: $elapsed_time 秒)"
            exit 0
        fi

        # 实时展示进度 (每 100 个密码更新一次)
        if ((attempts % 100 == 0)); then
            progress=$(echo "scale=2; $attempts / $total_combinations * 100" | bc)
            elapsed_time=$(( $(date +%s) - start_time))
            estimated_remaining_time=$(echo "scale=2; ($elapsed_time / $progress) * (100 - $progress)" | bc)
            echo -ne "\r进度: $progress%, 尝试次数: $attempts, 已耗时: $elapsed_time 秒, 预计剩余时间: $estimated_remaining_time 秒"
        fi
    done
done

end_time=$(date +%s)
elapsed_time=$((end_time - start_time))
echo -e "\n未找到匹配的密码 (尝试次数: $attempts, 耗时: $elapsed_time 秒)"
exit 1
