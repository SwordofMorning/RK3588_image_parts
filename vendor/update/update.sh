#!/bin/bash

# 李奇珈写的

# 严格模式
# set -euo pipefail

# 检查root权限
if [[ $EUID -ne 0 ]]; then
    echo "错误：此脚本必须以root权限运行" 1>&2
    exit 1
fi

# 参数检查：确保传入了镜像文件路径
if [ $# -eq 0 ]; then
    echo "错误：未提供镜像文件路径"
    echo "用法: $0 <path_to_new_image>"
    exit 1
fi

NEW_IMAGE="$1"

# 定义其他变量
DEVICE="/dev/mmcblk0p7"
MOUNT_POINT="/app"
BACKUP_FILE="app.img.bak"

# 验证镜像文件是否存在
if [[ ! -f "$NEW_IMAGE" ]]; then
    echo "错误：镜像文件 $NEW_IMAGE 不存在"
    exit 1
fi

# 查找进程并终止
fuser -km "$MOUNT_POINT"

# 1. 停止相关业务进程 (根据实际情况调整)
echo "正在停止业务进程..."

# 先尝试使用 killall 停止，并给予 2 秒缓冲时间
# 替换 litelog, mosquitto, my_ui_app 为你实际的进程名
SERVICES=("vo" "vi_vis" "pre" "gwp_demo" "HGD" "litelog" "mosquitto")

for svc in "${SERVICES[@]}"; do
    if pgrep -x "$svc" > /dev/null; then
        echo "停止服务: $svc"
        killall -9 "$svc" 2>/dev/null
    fi
done

# 2. 额外处理残留的 SQLite 锁或文件句柄
# 如果仍然有残留进程，执行强制清理
echo "确保所有相关进程已退出..."
sleep 5

# 卸载分区
echo "正在卸载 $MOUNT_POINT..."
if ! umount "$MOUNT_POINT"; then
    echo "卸载失败！请检查："
    lsof +D "$MOUNT_POINT" 2>/dev/null | grep "$MOUNT_POINT"
    exit 1
fi

# 写入新镜像
echo -e "\n开始写入新镜像 ($NEW_IMAGE) 到 $DEVICE..."
if ! dd if="$NEW_IMAGE" of="$DEVICE" bs=4M conv=fsync status=progress; then
    echo "镜像写入失败！请检查镜像完整性和设备状态"
    exit 1
fi
sync

# 重新挂载分区
echo -e "\n正在重新挂载 $DEVICE 到 $MOUNT_POINT..."
if ! mount "$DEVICE" "$MOUNT_POINT"; then
    echo "挂载失败！请检查文件系统完整性"
    exit 1
fi

echo -e "\n操作成功完成！建议执行以下检查："
echo "1. 验证挂载点内容：ls $MOUNT_POINT"
echo "2. 检查文件系统：fsck $DEVICE"
echo "3. 查看系统日志：dmesg | tail"

# 建议根据实际需求选择是否在此处重启
reboot
