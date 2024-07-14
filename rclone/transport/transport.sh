#!/bin/bash

# 定义原数据网盘和目标网盘列表
originalgdrive="gMediaOriginal:"  # 使用 rclone 的远程名
target_drives=("gtrandall:" "gtuser1:" "gtuser2:" "gtuser3:" "gtuser4:")  # 使用 rclone 的远程名

# 初始化计数器
counter=0

# 初始化失败文件列表
failed_files=()

function process_directory {
    local current_path="$1"
    local items_json=$(rclone lsjson "$originalgdrive$current_path")

    # 读取 json 输出并解析文件和目录
    echo "$items_json" | jq -c '.[]' | while read -r item; do
        ((counter++))
        local name=$(echo "$item" | jq -r '.Path')
        local is_dir=$(echo "$item" | jq -r '.IsDir')

        if [ "$is_dir" == "true" ]; then
            # 是目录，使用不同的gtransport创建目标目录并递归处理
            local new_path="$current_path$name/"
            local dest_index=$((counter % ${#target_drives[@]}))
            local dest_drive="${target_drives[$dest_index]}"

            echo "检查目录是否存在 $dest_drive$new_path"
            if ! rclone lsf "$dest_drive$new_path" > /dev/null 2>&1; then
                echo "创建目录 $dest_drive$new_path"
                if ! rclone mkdir "$dest_drive$new_path"; then
                    ((counter++))
                    echo "创建目录 $dest_drive$new_path 失败，尝试使用下一个传输器"
                    dest_index=$((counter % ${#target_drives[@]}))
                    dest_drive="${target_drives[$dest_index]}"

                    if ! rclone mkdir "$dest_drive$new_path"; then
                        echo "第二次尝试失败。将 $dest_drive$new_path 添加到失败文件列表。"
                        failed_files+=("$dest_drive$new_path")
                    fi
                fi
            else
                echo "目录已存在 $dest_drive$new_path"
            fi
            process_directory "$new_path"
        else
            # 是文件，检查是否是中断的文件
            local src="$originalgdrive$current_path$name"

            # 先递增计数器，然后使用更新后的计数器值选择目标网盘
            local dest_index=$((counter % ${#target_drives[@]}))
            local dest_drive="${target_drives[$dest_index]}"
            local dest="$dest_drive$current_path"

            echo "检查文件是否存在 $dest$name"
            if ! rclone lsf "$dest$name" > /dev/null 2>&1; then
                echo "复制 $src 到 $dest"
                if ! rclone copy "$src" "$dest" --progress; then
                    ((counter++))
                    echo "复制 $src 到 $dest 出错，尝试使用下一个传输器"
                    dest_index=$((counter % ${#target_drives[@]}))
                    dest_drive="${target_drives[$dest_index]}"
                    dest="$dest_drive$current_path"
                    echo "复制 $src 到 $dest"
                    if ! rclone copy "$src" "$dest" --progress; then
                        echo "第二次尝试失败。将 $src 添加到失败文件列表。"
                        # 如果两次都失败，则记录失败的文件
                        failed_files+=("$src")
                    fi
                fi
            else
                echo "文件已存在 $dest$name"
            fi
        fi
    done
}

# 开始处理根目录
process_directory ""

echo "文件传输完成！"
