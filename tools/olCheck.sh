#!/bin/bash

# オーバレイモードのドライブの存在を確認し、プロンプトを変更します。
#
#                                              Copyright (c) 2021 Wataru KUNINO

# インストール方法
#   git clone https://bokunimo.net/git/udp.git

# 使用方法:
#   source ~/udp/udp_monitor/olCheck.sh
# または
#   .bashrcに下記を追加する
#     if [ -f ~/udp/udp_monitor/olCheck.sh ]; then
#         . ~/udp/udp_monitor/olCheck.sh
#     fi

name="olCheck.sh"
if [ "$0" != "-bash" ]; then
	name=${0}
fi

echo "Usage: source" ${name} "[on|off|status]"

echo -n "Overlay Mode = "
i=`df|grep "^overlay"| tail -1`
if [ "$i" = "" ]; then
	echo -n "unlocked"
	olfs=0
else
	echo -n "Locked"
	olfs=1
fi

if [ "${1:0:4}" = "stat" ]; then
	sudo raspi-config nonint get_overlay_now
	if [ $? -ne 0 ]; then
		echo -n ", unlocked"
		olfs=0
	else
		echo -n ", Locked"
		olfs=1
	fi
fi

if [ ${olfs} -eq 0 ]; then
	PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w \$\[\033[00m\] '
else
	PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[01;31m\](LOCKED)\[\033[00m\]:\[\033[01;34m\]\w \$\[\033[00m\] '
fi

olfs_new=${olfs}
if [ "${1}" = "off" ]; then
	echo
	sudo raspi-config nonint disable_overlayfs
	echo -n "Overlay Mode = unlock"
	olfs_new=0
fi
if [ "${1}" = "on" ]; then
	echo
	echo "Config is in progress. しばらくお待ちください"
	sudo raspi-config nonint enable_overlayfs
	echo -n "Overlay Mode = Lock"
	olfs_new=1
fi

if [ ${olfs} -ne ${olfs_new} ]; then
	echo "; System Reboot Required!"
	echo -n "> sudo reboot"
fi

echo

# 設定をコマンドで行う方法
# sudo raspi-config nonint enable_overlayfs
# sudo raspi-config nonint disable_overlayfs
# sudo raspi-config nonint get_overlay_now
