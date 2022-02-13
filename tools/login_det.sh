#!/bin/bash
#############
# login det for Raspberry Pi; SSH ログインを監視する
#############

KEY="xxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   # IFTTTのKey(鍵)
URL="https://maker.ifttt.com/trigger/"              # IFTTTのURL(変更不要)
IP_TALK="192.168.1.10"                              # Wi-Fiコンシェルジェ音声アナウンス担当

if [ "${1}" = "std_in" ]; then
	while read stdin; do
		data=`echo ${stdin}|grep -e "password" -e "Successful" -e "FAILED"`
		if [ -n "${data}" ]; then
			DATE=`date "+%Y/%m/%d %R"`
			data=`echo ${data}|cut -d" " -f6-`
			if [ -n "${data}" ]; then
				event=`echo ${data}|cut -d" " -f1`
				DATA=""
				if [ "${event}" = "Failed" ] || [ "${event}" = "FAILED" ]; then
					DATA="Raspberry Piに不正なSSHアクセスがありました。ログを確認してください。"
					curl -s -m3 ${IP_TALK}/?TEXT=\"${DATA}\"\&VOL=100 &> /dev/null &
					curl -X POST -H "Content-Type: application/json" -d '{"value1":"'${DATA}'"}' ${URL}notify/with/key/${KEY} &> /dev/null &
				fi
				if [ "${event}" = "Successful" ]; then
					DATA="ルートへのアクセスがありました。"
					curl -s -m3 ${IP_TALK}/?TEXT=\"${DATA}\"\&VOL=50 &> /dev/null &
					curl -X POST -H "Content-Type: application/json" -d '{"value1":"'${DATA}'"}' ${URL}notify/with/key/${KEY} &> /dev/null &
				fi
				if [ "${event}" = "Accepted" ]; then
					DATA="ログインしました。"
					curl -s -m3 ${IP_TALK}/?TEXT=\"${DATA}\"\&VOL=50 &> /dev/null &
				fi
				if [ -n "${DATA}" ]; then
					echo ${DATE},${data} | tee -a login_det.log
				fi
			fi
		fi
	done
	exit
else
	while true; do
		nice -n 10 tail -F /var/log/auth.log| ${0} std_in
	done
	exit
fi
exit
###########################################################################
tailf /var/log/auth.log | grep password |awk '{print "{\"value1\":\""$6"\"}"}'|curl -s -m3 -XPOST -H "Content-Type: application/json" -d @- ${URL}notify/with/key/${KEY}

cat > login_det.sh
ペースト
[Ctrl]+[D]
chmod a+x login_det.sh
sudo su
sudo cat >> /etc/rc.local
nohup /home/pi/login_det.sh &> /dev/null &
[Ctrl]+[D]
# exitがあるばあいは、exitの前に移動
