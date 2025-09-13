#!/bin/bash

# 检查是否传入两个参数
if [ $# -ne 2 ]; then
    echo "用法: $0 <待转换图片目录> <输出webp图片目录>"
    exit 1
fi

# 获取输入和输出目录，去掉最后的斜杠（如果有）
INPUT_DIR="${1%/}"
OUTPUT_DIR="${2%/}"

# 检查输入目录是否存在
if [ ! -d "$INPUT_DIR" ]; then
    echo "错误: 目录 $INPUT_DIR 不存在。"
    exit 1
fi

# 创建输出目录
mkdir -p "$OUTPUT_DIR"

# 遍历所有图片文件
find "$INPUT_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | while read -r file; do
    # 获取相对路径
    REL_PATH="${file#$INPUT_DIR/}"
    OUTPUT_PATH="$OUTPUT_DIR/$(dirname "$REL_PATH")"
    mkdir -p "$OUTPUT_PATH"

    EXT="${file##*.}"
    EXT_LOWER=$(echo "$EXT" | tr 'A-Z' 'a-z')

    if [ "$EXT_LOWER" = "webp" ]; then
        # 直接复制 webp 文件
        cp "$file" "$OUTPUT_PATH/"
        echo "已复制: $file -> $OUTPUT_PATH/"
    else
        # 转换为 webp
        FILENAME_NO_EXT="${REL_PATH%.*}"
        OUTPUT_FILE="$OUTPUT_DIR/${FILENAME_NO_EXT}.webp"
        echo "正在转换: $file -> $OUTPUT_FILE"
        cwebp -q 80 "$file" -o "$OUTPUT_FILE" > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "✅ 成功"
        else
            echo "❌ 失败"
        fi
    fi
done

echo "✅ 全部处理完成，输出目录: $OUTPUT_DIR"