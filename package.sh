#!/bin/bash

# 检查参数
if [ $# -ne 1 ]; then
    echo "Usage: $0 <partition_name>"
    echo "Supported partitions: app, oemven, userdata"
    exit 1
fi

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 分区名称
PARTITION=$1

# 定义固定大小分区的大小
FIXED_SIZE="128M"

# 检查分区名是否有效并设置大小
case $PARTITION in
    "app"|"oemven")
        # 使用固定大小
        PARTITION_SIZE=$FIXED_SIZE
        ;;
    "userdata")
        # 使用自动大小
        PARTITION_SIZE="auto"
        ;;
    *)
        echo "Error: Invalid partition name"
        echo "Supported partitions: app, oemven, userdata"
        exit 1
        ;;
esac

# 设置参数
SOURCE_DIR="${SCRIPT_DIR}/${PARTITION}"
IMAGE_NAME="${PARTITION}.img"
FS_TYPE="ext4"

# 检查源目录是否存在
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory '$SOURCE_DIR' not found"
    exit 1
fi

# 检查mk-image.sh是否存在
if [ ! -f "${SCRIPT_DIR}/mk-image.sh" ]; then
    echo "Error: mk-image.sh not found in $SCRIPT_DIR"
    exit 1
fi

# 执行打包命令
echo "Creating image for $PARTITION..."
echo "Source: $SOURCE_DIR"
echo "Target: $IMAGE_NAME"
echo "Filesystem: $FS_TYPE"
echo "Size: $PARTITION_SIZE"

"${SCRIPT_DIR}/mk-image.sh" "$SOURCE_DIR" "$IMAGE_NAME" "$FS_TYPE" "$PARTITION_SIZE" "$PARTITION"

# 检查执行结果
if [ $? -eq 0 ]; then
    echo "Successfully created $IMAGE_NAME"
else
    echo "Error: Failed to create $IMAGE_NAME"
    exit 1
fi