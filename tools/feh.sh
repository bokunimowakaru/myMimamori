#!/bin/bash

# Picturesフォルダ内の写真をスライドショー表示します
#
#                                         Copyright (c) 2021-2022 Wataru KUNINO

# 最新版：
# https://github.com/bokunimowakaru/myMimamori/blob/master/tools/feh.sh

# インストール方法
#   sudo apt-get install feh
#   cd
#   git clone https://bokunimo.net/git/myMimamori.git

# 使用方法:
#   fehを自動起動するには以下のコマンドを/etc/rc.localに入れておく
#       sudo -u pi /home/pi/myMimamori/tools/feh.sh delay &
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
