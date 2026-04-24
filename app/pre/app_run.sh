#! /bin/bash

echo 1 > /dev/jp_hgd_gpio_ctl_enable_refrigerator

export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/var/run}
export LD_LIBRARY_PATH=/app/pre/test_lib/:$LD_LIBRARY_PATH

modetest -aw 57:zpos:1

killall bootanimation

/app/pre/pre &

/app/pre/vi_vis &

/app/pre/vo &

/app/ui/HGD &

amixer -c 0 cset numid=12 80%
amixer -c 0 cset numid=20 245
amixer -c 0 cset numid=13 100%
amixer -c 0 cset numid=16 0
amixer -c 0 cset numid=21 0
/app/pre/gwp_demo >/dev/null 2>&1  &
