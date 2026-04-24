#!/bin/bash

# 检查参数
if [ $# -ne 1 ]; then
    echo "Usage: $0 <partition_name>"
    echo "Supported partitions: app, oemven, userdata, vendor, hold"
    exit 1
fi

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 分区名称
PARTITION=$1

# 定义不同分区的大小
FIXED_SIZE_APP="512M"
FIXED_SIZE_LARGE="128M"
FIXED_SIZE_SMALL="16M"

# 检查分区名是否有效并设置大小
case $PARTITION in
    "app")
        # 使用较大固定大小
        PARTITION_SIZE=$FIXED_SIZE_APP
        ;;
    "oemven")
        PARTITION_SIZE=$FIXED_SIZE_LARGE
        ;;
    "vendor"|"hold")
        # 使用较小固定大小
        PARTITION_SIZE=$FIXED_SIZE_SMALL
        ;;
    "userdata")
        # 使用自动大小
        PARTITION_SIZE="auto"
        ;;
    *)
        echo "Error: Invalid partition name"
        echo "Supported partitions: app, oemven, userdata, vendor, hold"
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