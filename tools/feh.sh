#!/bin/bash

# Picturesフォルダ内の写真をスライドショー表示します
#
#                                              Copyright (c) 2021 Wataru KUNINO

# インストール方法
#   sudo apt-get install feh
#   git clone https://bokunimo.net/git/udp.git

# 使用方法:
#   fehを自動起動するには以下のコマンドを/etc/rc.localに入れておく
#       sudo -u pi /home/pi/feh.sh delay &
#

echo "Usage:" $0 "[start|stop|delay]"

PID=`pidof feh`
if [ "${PID}" != "" ] || [ "${1}" = "stop" ]; then
        kill $PID
fi
export DISPLAY=:0
XAUTHORITY=/home/pi/.Xauthority
if [ $# -eq 0 ] || [ "${1}" = "start" ]; then
        /usr/bin/feh -FZxYD10 /home/pi/Pictures/ &
fi
if [ "${1}" = "delay" ]; then
        sleep 30 && /usr/bin/feh -FZxYD10 /home/pi/Pictures/ &
fi
exit
