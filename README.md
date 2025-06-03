# HGD fs分区

```sh
# App分区
/dev/mmcblk0p7  ext4      119M   60M   51M  55% /app
# OEM分区
/dev/mmcblk0p8  ext4      119M  152K  110M   1% /oemven
# 制造商保留分区，用于存放系统库
/dev/mmcblk0p9  ext4       15M  4.4M  8.8M  34% /vendor
# 保留分区，用于存放设备信息等永久存储文件
/dev/mmcblk0p10 ext4       15M   15K   14M   1% /hold
# 用户数据
/dev/mmcblk0p11 ext4       26G  303K   25G   1% /userdata
```