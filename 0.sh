#!/bin/bash

# 设置文件路径
file_path="文件路径"

# 保存可修改文件的列表
modifiable_files=$(find "$file_path" -type f)

# 列出可修改的文件名称
echo "可修改的文件名称："
echo "$modifiable_files" | while IFS= read -r file; do
    # 从文件名中提取时间信息
    timestamp=$(basename "$file" | grep -oE '[0-9]{8}_[0-9]{6}')
    # 如果找到时间信息，则显示文件名称
    if [ -n "$timestamp" ]; then
        echo "$(basename "$file")"
    fi
done

# 提示用户选择是否修改文件名称
read -p "是否修改文件名称？(y/n): " choice

# 初始化计数器
modified_count=0
skipped_count=0

# 初始化列表
modified_list=""
skipped_list=""

# 遍历可修改文件列表
echo "$modifiable_files" | while IFS= read -r file; do
    # 从文件名中提取时间信息
    timestamp=$(basename "$file" | grep -oE '[0-9]{8}_[0-9]{6}')
    # 如果找到时间信息，则设置文件的修改时间
    if [ -n "$timestamp" ]; then
        echo "Found timestamp: $timestamp"  # 添加调试信息
        # 使用date命令将日期时间字符串转换为秒数
        timestamp_seconds=$(date -d "${timestamp:0:4}-${timestamp:4:2}-${timestamp:6:2} ${timestamp:9:2}:${timestamp:11:2}:${timestamp:13:2}" +%s)
        echo "Converted timestamp: $timestamp_seconds"  # 添加调试信息
        # 如果用户选择修改文件名称，则修改文件名
        if [ "$choice" == "y" ]; then
            new_file_name="${file//${timestamp}_}"
            mv "$file" "$new_file_name"
            ((modified_count++))
            modified_list+="\n$new_file_name"
        else
            ((skipped_count++))
            skipped_list+="\n$(basename "$file")"
        fi
        # 使用touch命令设置文件的修改时间
        touch -d "@$timestamp_seconds" "$file"
    fi
done
